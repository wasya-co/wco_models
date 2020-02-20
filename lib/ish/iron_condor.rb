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

  ## the price of common when it enters the position
  field :enter_price, type: Float
  field :call_sell_leg, type: Float
  field :call_buy_leg, type: Float
  field :put_sell_leg, type: Float
  field :put_buy_leg, type: Float

  field :iv_annual, type: Float
  def iv_annual
    18 # QQQ
  end
  def iv_period
    n_days = created_on.business_days_until expires_on
    result = iv_annual.to_f / sqrt(252/n_days)
  end
  alias_method :period_iv, :iv_period

  ## how close to a sell leg I need to be to take followup action
  def panic_percentage
    0.01 # 1% for QQQ
  end

  def buysell_spread
    1 # $1 for QQQ
  end

  def get_call_sell_leg
    result = enter_price * ( 1 - period_iv/100 )
    result = result.ceil
  end
  def get_call_buy_leg
    call_sell_leg + buysell_spread
  end

  def get_put_sell_leg
    result = enter_price * ( 1 - period_iv/100 )
    result = result.floor
  end
  def get_put_buy_leg
    put_sell_leg - buysell_spread
  end

  def upper_panic_threshold
    result = call_sell_leg * ( 1 - panic_percentage )
  end

  def lower_panic_threshold
    result = put_sell_leg * ( 1 + panic_percentage )
  end

  def new_multileg_order_example
    tiker = 'QQQ'
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
            SecTyp="OPT" CFI="OC" Sym="#{tiker}"/>
        </Ord>
        <Ord OrdQty="#{n_contracts}" PosEfct="O">
          <Leg Side="1" Strk="#{buy_strike}" 
            Mat="#{expiration.strftime('%Y-%m-%d')}T00:00:00.000-05:00" MMY="#{expiration.strftime('%y%m')}" 
            SecTyp="OPT" CFI="OC" Sym="#{tiker}"/>
        </Ord>
      </NewOrdMleg>
    </FIXML>
    AOL
  end

  def new_purchase_trash
    tiker = 'AXU'
    px = 2.06
    account_id = ALLY_CREDS[:account_id]
    n_contracts = 1
    strike = 2.06

    xml = <<~AOL
      <FIXML xmlns="http://www.fixprotocol.org/FIXML-5-0-SP2">
        <Order TmInForce="0" Typ="1" Side="1" Acct="#{account_id}">
          <Instrmt SecTyp="CS" Sym="#{tiker}"/>
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
  def rollup_tmpl access_token=nil, natural=nil
    @access_token ||= access_token

    new_call_sell_leg = ( natural * ( 1 + period_iv ) ).ceil
    new_call_buy_leg = new_call_sell_leg + buysell_spread

    # get the costs of the option first, to compute `Px`
    ymd = condor.expires_on.strftime('%y%m%d')
    price = (new_call_sell_leg*1000).to_i.to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=QQQ#{ymd}C#{price}"
    puts! path, 'path sell'
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_sell = JSON.parse response.body
    json_sell.deep_symbolize_keys!
    json_sell_bid = json_sell[:response][:quotes][:quote][:bid].to_f
    json_sell_ask = json_sell[:response][:quotes][:quote][:ask].to_f
    puts! json_sell, 'json sell'

    price = (new_call_buy_leg*1000).to_s.rjust(8, '0')
    path = "/v1/market/ext/quotes.json?symbols=QQQ#{ymd}C#{price}"
    response = @access_token.post(path, {'Accept' => 'application/json'})
    json_buy = JSON.parse response.body
    json_buy.deep_symbolize_keys!
    json_buy_bid = json_buy[:response][:quotes][:quote][:bid].to_f
    json_buy_ask = json_buy[:response][:quotes][:quote][:ask].to_f

    px_sell = ( json_sell_bid + json_sell_ask )/ 2
    px_sell = px_sell.round 2
    px_buy = ( json_buy_bid + json_buy_ask )/ 2
    px_buy = px_buy.round 2
    px = px_sell - px_buy
    px = ( px * 20 ).round.to_f / 20 # down to nearest 0.05
    puts! px, 'px'

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
              Strk="#{call_sell_leg}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00"
              MMY="#{expires_on.strftime('%Y%m')}"
              SecTyp="OPT"
              CFI="OC"
              Sym="#{tiker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="C" >
            <Leg 
              Side="2" 
              Strk="#{call_buy_leg}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{tiker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="2" 
              Strk="#{new_call_sell_leg}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{tiker}" />
          </Ord>
          <Ord OrdQty="#{n_contracts}" PosEfct="O" >
            <Leg 
              Side="1" 
              Strk="#{new_call_buy_leg}" 
              Mat="#{expires_on.strftime('%Y-%m-%d')}T00:00:00.000‐05:00" 
              MMY="#{expires_on.strftime('%Y%m')}" 
              SecTyp="OPT" 
              CFI="OC" 
              Sym="#{tiker}" />
          </Ord>
        </NewOrdMleg>
      </FIXML>
    AOL
  end

end
