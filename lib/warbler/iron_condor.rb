
=begin

c.update_attributes( call_sell_strike: 242, call_buy_strike: 243, put_sell_strike: 229, put_buy_strike: 228 )

=end

class Ish::IronCondor
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'ish_iron_condor'

  field :expires_on, type: Date
  validates :expires_on, presence: true
  field :n_contracts, type: Integer
  validates :n_contracts, presence: true
  field :ticker
  validates :ticker, uniqueness: { scope: :expires_on }
  validates :ticker, presence: true

  #
  # Internal, below
  #

  def created_on; created_at.to_date; end

  def self.all_filled
    where( status: :filled )
  end

  STATUSES = [ :queued, :placed, :filled, :rolling_up, :rolling_down, :rolled_up, :rolled_down, :expired ]
  field :status
  field :enter_price,          type: Float
  field :call_sell_strike,     type: Float
  field :call_buy_strike,      type: Float
  field :put_sell_strike,      type: Float
  field :put_buy_strike,       type: Float
  field :new_call_sell_strike, type: Float
  field :new_call_buy_strike,  type: Float
  field :new_put_sell_strike,  type: Float
  field :new_put_buy_strike,   type: Float

  field :iv_annual, type: Float
  def iv_period
    n_days = created_on.business_days_until expires_on
    result = iv_annual.to_f / Math.sqrt(252/n_days)
  end
  alias_method :period_iv, :iv_period

  ## how close to a sell leg I need to be to take followup action
  def panic_percentage
    0.01 # 1% for QQQ
  end

  def buysell_spread
    1 # $1 for QQQ
  end

  def get_call_sell_strike
    result = enter_price * ( 1 - period_iv/100 )
    result = result.ceil
  end
  def get_call_buy_strike
    call_sell_strike + buysell_spread
  end

  def get_put_sell_strike
    result = enter_price * ( 1 - period_iv/100 )
    result = result.floor
  end
  def get_put_buy_strike
    put_sell_strike - buysell_spread
  end

  def upper_panic_threshold
    result = call_sell_strike * ( 1 - panic_percentage )
  end

  def lower_panic_threshold
    result = put_sell_strike * ( 1 + panic_percentage )
  end

  def new_multileg_order_example_done
    ticker = 'QQQ'
    px = 0.08
    account_id = ALLY_CREDS[:account_id]
    n_contracts = 1
    sell_strike = 237.0
    buy_strike = 237.5
    expiration = '2020-02-21'.to_date

    tmpl = <<~AOL
    <FIXML xmlns="http://www.fixprotocol.org/FIXML-5-0-SP2">
      <NewOrdMleg TmInForce="0" Px="#{px}" OrdTyp="2" Acct="#{account_id}">
        <Ord OrdQty="#{n_contracts}" PosEfct="O">
          <Leg Side="2" Strk="#{sell_strike}" 
            Mat="#{expiration.strftime('%Y-%m-%d')}T00:00:00.000-05:00" MMY="#{expiration.strftime('%y%m')}" 
            SecTyp="OPT" CFI="OC" Sym="#{ticker}"/>
        </Ord>
        <Ord OrdQty="#{n_contracts}" PosEfct="O">
          <Leg Side="1" Strk="#{buy_strike}" 
            Mat="#{expiration.strftime('%Y-%m-%d')}T00:00:00.000-05:00" MMY="#{expiration.strftime('%y%m')}" 
            SecTyp="OPT" CFI="OC" Sym="#{ticker}"/>
        </Ord>
      </NewOrdMleg>
    </FIXML>
    AOL
  end

  def new_purchase_trash
    ticker = 'AXU'
    px = 2.06
    account_id = ALLY_CREDS[:account_id]
    n_contracts = 1
    strike = 2.06

    xml = <<~AOL
      <FIXML xmlns="http://www.fixprotocol.org/FIXML-5-0-SP2">
        <Order TmInForce="0" Typ="1" Side="1" Acct="#{account_id}">
          <Instrmt SecTyp="CS" Sym="#{ticker}"/>
          <OrdQty Qty="1"/>
        </Order>
      </FIXML>
    AOL
  end

  ## https://www.ally.com/api/invest/documentation/fixml/
  ## https://www.ally.com/api/invest/documentation/trading/
  ## follow up, roll up
  ## buy call to close
  ## sell call to close
  ## sell call to open
  ## buy call to open
  def rollup_xml access_token=nil, natural=nil
    @access_token ||= access_token

    new_call_sell_strike = ( natural * ( 1 + period_iv ) ).ceil
    new_call_buy_strike = new_call_sell_strike + buysell_spread

    # get the costs of the option first, to compute `Px`
    ymd = expires_on.strftime('%y%m%d')
    price8 = (new_call_sell_strike*1000).to_i.to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=#{ticker}#{ymd}C#{price8}"
    puts! path, 'path sell'
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_sell = JSON.parse( response.body ).deep_symbolize_keys
    json_sell_bid = json_sell[:response][:quotes][:quote][:bid].to_f
    json_sell_ask = json_sell[:response][:quotes][:quote][:ask].to_f
    
    price8 = (new_call_buy_strike*1000).to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=#{ticker}#{ymd}C#{price8}"
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_buy = JSON.parse( response.body ).deep_symbolize_keys
    json_buy_bid = json_buy[:response][:quotes][:quote][:bid].to_f
    json_buy_ask = json_buy[:response][:quotes][:quote][:ask].to_f

    px_sell = ( json_sell_bid.to_f + json_sell_ask ) / 2
    px_sell = px_sell # .round 2
    px_buy = ( json_buy_bid + json_buy_ask )/ 2
    px_buy = px_buy # .round 2
    px = px_sell - px_buy
    px = ( px * 20 ).round.to_f / 20 # down to nearest 0.05
    
    json_puts! json_sell, 'json_sell'
    json_puts! json_buy, 'json_buy'
    puts! px, '^00 - px'

=begin
    update( status: :rolling_up, 
      new_call_sell_strike: new_call_sell_strike, 
      new_call_buy_strike: new_call_buy_strike )
=end

    rollup_tmpl =<<~AOL
      <?xml version="1.0" encoding="UTF-8"?>
      <FIXML xmlns="http://www.fixprotocol.org/FIXML-5-0-SP2">
        <NewOrdMleg
          OrdTyp="2"
          Px="#{px}"
          Acct="#{ALLY_CREDS[:account_id]}" 
          TmInForce="0"
        >
          <Ord OrdQty="#{n_contracts}" PosEfct="C" >
            <Leg 
              AcctTyp="5" 
              Side="1" 
              Strk="#{call_sell_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00"
              MMY="#{expires_on.strftime('%Y%m')}"
              SecTyp="OPT"
              CFI="OC"
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="C" >
            <Leg 
              Side="2" 
              Strk="#{call_buy_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="2" 
              Strk="#{new_call_sell_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="1" 
              Strk="#{new_call_buy_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{ticker}" />
          </Ord>
        </NewOrdMleg>
      </FIXML>
    AOL
  end

  def rolldown_xml access_token=nil, natural=nil
    @access_token ||= access_token

    new_put_sell_strike = ( natural * ( 1 - period_iv ) ).floor
    new_put_buy_strike = new_put_sell_strike - buysell_spread

    # get the costs of the option first, to compute `Px`
    ymd = expires_on.strftime('%y%m%d')
    price8 = (new_put_sell_strike*1000).to_i.to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=#{ticker}#{ymd}C#{price8}"
    puts! path, 'path sell'
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_sell = JSON.parse( response.body ).deep_symbolize_keys
    json_sell_bid = json_sell[:response][:quotes][:quote][:bid].to_f
    json_sell_ask = json_sell[:response][:quotes][:quote][:ask].to_f
    json_puts! json_sell, 'json_sell'

    price8 = (new_put_buy_strike*1000).to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=#{ticker}#{ymd}C#{price8}"
    puts! path, 'path buy'
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_buy = JSON.parse( response.body ).deep_symbolize_keys
    json_buy_bid = json_buy[:response][:quotes][:quote][:bid].to_f
    json_buy_ask = json_buy[:response][:quotes][:quote][:ask].to_f
    json_puts! json_buy, 'json_buy'

    px_sell = ( json_sell_bid.to_f + json_sell_ask ) / 2
    px_sell = px_sell # .round 2
    px_buy = ( json_buy_bid + json_buy_ask )/ 2
    px_buy = px_buy # .round 2
    px = px_sell - px_buy
    px = ( px * 20 ).round.to_f / 20 # down to nearest 0.05
    puts! px, 'px'

=begin
    update( status: :rolling_down, 
      new_put_sell_strike: new_put_sell_strike, 
      new_put_buy_strike: new_put_buy_strike )
=end

    rollup_tmpl =<<~AOL
      <?xml version="1.0" encoding="UTF-8"?>
      <FIXML xmlns="http://www.fixprotocol.org/FIXML-5-0-SP2">
        <NewOrdMleg
          OrdTyp="2"
          Px="#{px}"
          Acct="#{ALLY_CREDS[:account_id]}" 
          TmInForce="0"
        >
          <Ord OrdQty="#{n_contracts}" PosEfct="C" >
            <Leg 
              AcctTyp="5" 
              Side="1" 
              Strk="#{put_sell_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00"
              MMY="#{expires_on.strftime('%Y%m')}"
              SecTyp="OPT"
              CFI="OP"
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="C" >
            <Leg 
              Side="2" 
              Strk="#{put_buy_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OP" 
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="2" 
              Strk="#{new_put_sell_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OP" 
              Sym="#{ticker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="1" 
              Strk="#{new_put_buy_strike}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OP" 
              Sym="#{ticker}" />
          </Ord>
        </NewOrdMleg>
      </FIXML>
    AOL
  end

end
