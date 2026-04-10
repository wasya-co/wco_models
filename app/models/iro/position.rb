
class Iro::Position
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_positions'

  field :next_gain_loss_amount, type: :float

  STATUS_ACTIVE   = 'active'
  STATUS_CLOSED   = 'closed'
  STATUS_PREPARE  = 'prepare'
  STATUS_PROPOSED = 'proposed'
  ## one more, 'selected' after proposed?
  STATUS_PENDING  = 'pending' ## 'working'
  STATUSES = [ nil, STATUS_CLOSED, STATUS_ACTIVE, STATUS_PREPARE, STATUS_PROPOSED, STATUS_PENDING ]
  field :status
  validates :status, presence: true
  scope :active,   ->{ where( status: 'active' ) }
  scope :proposed, ->{ where( status: 'proposed' ) }

  def status_label st
    labels = {}
    labels[STATUS_PROPOSED] = 'Selected.'
    return labels[st] || st
  end

  field :intent

  belongs_to :purse, class_name: 'Iro::Purse',    inverse_of: :positions
  index({ purse_id: 1, ticker: 1 })

  belongs_to :stock, class_name: 'Iro::Stock',    inverse_of: :positions
  field :ticker
  def ticker
    if !self[:ticker]
      self[:ticker] = stock.ticker
      self.save
    end
    self[:ticker]
  end

  belongs_to :strategy, class_name: 'Iro::Strategy', inverse_of: :positions
  delegate :long_or_short,   to: :strategy
  delegate :credit_or_debit, to: :strategy

  field :put_call, type: :string
  validates :put_call, presence: true
  def put_call
    self[:put_call] || self.strategy.put_call
  end


  belongs_to :next_strategy, class_name: 'Iro::Strategy', inverse_of: :next_position, optional: true


  ## there are many of these, for viewing on the 'roll' view
  belongs_to :prev,     class_name: 'Iro::Position', inverse_of: :nxts,    optional: true
  has_many   :nxts,     class_name: 'Iro::Position', inverse_of: :prev

  ## 2026-02-26 using this one.
  belongs_to :autonxt,  class_name: 'Iro::Position', inverse_of: :autoprev, optional: true
  has_one    :autoprev, class_name: 'Iro::Position', inverse_of: :autonxt


  ## Options

  belongs_to :inner, class_name: 'Iro::Option', inverse_of: :pos_of_inner
  validates_associated :inner

  belongs_to :outer, class_name: 'Iro::Option', inverse_of: :pos_of_outer, optional: true
  validates_associated :outer

  accepts_nested_attributes_for :inner, :outer

  field     :outer_strike, type: :float
  validates :outer_strike, presence: true ## 2026-02-24 only to make finding easier.

  field     :inner_strike, type: :float
  validates :inner_strike, presence: true ## 2026-02-24 only to make finding easier.

  field :expires_on
  validates :expires_on, presence: true

  field :quantity, type: :integer
  validates :quantity, presence: true
  def q; quantity; end

  field :begin_on

  field :end_on

  field :schwab_order_id, type: :integer
  field :schwab_status

  def begin_delta
    strategy.send("begin_delta_#{strategy.kind}", self)
  end
  def end_delta
    strategy.send("end_delta_#{strategy.kind}", self)
  end

  def breakeven
    send("breakeven_#{strategy.kind}")
  end
  def breakeven_covered_call
    p = self
    p.inner.strike + p.inner.begin_price
  end
  def breakeven_long_debit_call_spread
    p = self
    p.inner.strike - p.max_gain
  end
  ## 2026-02-23
  def breakeven_short_credit_call_spread
    p = self
    p.inner.strike + p.max_gain
  end
  ## 2026-02-23
  def breakeven_long_credit_put_spread
    p = self
    p.inner.strike - p.max_gain
  end


  def current_underlying_strike
    Iro::Stock.find_by( ticker: ticker ).last
  end

  def refresh
    out = Tda::Option.get_quote({
      contractType:   'CALL',
      strike:         strike,
      expirationDate: expires_on,
      ticker:         ticker,
    })
    update({
      end_delta: out[:delta],
      end_price: out[:last],
    })
    print '^'
  end


  field :pending_price, type: :float

  ## credit spread only
  def close_price
    pos = self
    out = pos.outer.end_price - pos.inner.end_price
    return out.round(2)
  end

  ## credit-spread
  def open_price
    pos = self
    out = pos.inner.begin_price - pos.outer.begin_price
    return out.round(2)
  end

  def roll_price
    pos = self
    out = pos.autoprev.outer.end_price - pos.autoprev.inner.end_price + pos.inner.begin_price - pos.outer.begin_price
    return out.round(2)
  end


  def net_percent
    net_amount / max_gain
  end
  def net_amount # each
    self.send("net_amount_#{strategy.kind}")
  end
  def net_amount_covered_call
    inner.begin_price - inner.end_price
  end
  ## 2025-10-14 tested
  def net_amount_long_credit_put_spread ## each
    inner.begin_price - outer.begin_price + outer.end_price - inner.end_price
  end
  ## 2026-02-19 tested
  def net_amount_short_credit_call_spread
    return net_amount_long_credit_put_spread
  end

  def max_gain # each
    strategy.send("max_gain_#{strategy.kind}", self)
  end
  def max_loss # each
    strategy.send("max_loss_#{strategy.kind}", self)
  end


  def sync
    if schwab_order_id
      outs = Tda::Order.check_status schwab_order_id
      update({ schwab_status: outs['status'] })
      if [ Tda::Order::STATUS_FILLED, Tda::Order::STATUS_REPLACED ].include?( outs['status'] )
        ## update amounts.
        purse.update({ available_amount: purse.available_amount + next_gain_loss_amount*quantity*100 })
        ## make this one active
        update({ status: Iro::Position::STATUS_ACTIVE, next_gain_loss_amount: nil })
        ## make previous one closed
        autoprev.update({ status: Iro::Position::STATUS_CLOSED })
      end
    end
    inner.sync
    outer.sync
  end

  def schwab_query
    pos = self
    case pos.intent
    when Iro::Strategy::INTENT_OPEN
      the_q = Tda::Order.credit_spread_q pos
    when Iro::Strategy::INTENT_ROLL
      the_q = Tda::Order.roll_credit_call_spread_q pos
    else
      throw "prp - #schwab_query undefined for position #{pos.inspect}"
    end
    return the_q
  end

  def self.sync_all
    @positions = Iro::Position.where( :status.in => [ 'active', 'pending' ] )
    expiration_dates = @positions.map { |p| p.expires_on.to_s }.sort
    # puts! expiration_dates, 'expiration_dates'

    count = 1
    @positions.each do |pos|
      # puts! pos.to_s, 'pos TMP'

      quotes_h = Tda::Option.get_quotes_h({
        contractType: 'ALL',
        ticker:  pos.ticker,
        fromDate: expiration_dates.first,
        toDate: expiration_dates.last,
      })

      pos.inner.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:price]
      pos.inner.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.inner.strike][:delta]
      pos.inner.save ? print("#{count}^") : print("#{count}X")
      if [ Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD, Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD ].include?( pos.strategy.kind )
        pos.outer.end_price = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:price]
        pos.outer.end_delta = quotes_h[pos.expires_on.to_s][pos.put_call][pos.outer.strike][:delta]
        pos.outer.save ? print('^') : print('X')
      end
      count = count+1
    end

    print 'synced-all.'
  end



  ##
  ## decisions
  ##

  field :next_reasons, type: :array, default: []
  field :rollp, type: :float

  ## should_roll?
  def calc_rollp
    pos = self
    pos.next_reasons = []

    out = strategy.send("calc_rollp_#{strategy.kind}", pos )

    pos.rollp = out[0]
    pos.next_reasons.push out[1]
    save
  end

  def calc_nxt
    pos = self
    # puts! pos, '#calc_nxt...'

    ## 7 days ahead - not configurable
    params = {
      contractType: pos.put_call,
      expirationDate: next_expires_on,
      ticker: ticker,
    }
    # puts! params, 'ze params'
    outs = Tda::Option.get_quotes(params)
    # puts! outs, 'outs'
    outs_bk = outs.dup

    ## cleanup mid-increments
    outs = outs.select do |out|
      ( out[:strikePrice] - pos.inner.strike ) % strategy.stock.options_price_increment == 0
    end

    outs = outs.select do |out|
      out[:bidSize] + out[:askSize] > 0
    end

    if 'CALL' == pos.put_call
      ;
    elsif 'PUT' == pos.put_call
      outs = outs.reverse
    end
    # puts! outs, '#calc_nxt.outs -> 2'

    ## next_inner_strike
    if strategy.next_inner_strike.present?
      outs = outs.select do |out|
        if Iro::Strategy::CREDIT == pos.credit_or_debit
          if Iro::Strategy::SHORT == pos.long_or_short
            ## short credit call
            out[:strikePrice] >= strategy.next_inner_strike
          elsif Iro::Strategy::LONG == pos.long_or_short
            ## long credit put
            out[:strikePrice] <= strategy.next_inner_strike
          end
        else
          raise 'zt3 - @TODO: implement, debit spreads'
        end
      end
      # puts! outs[0][:strikePrice], 'after calc next_inner_strike'
      # puts! outs, 'outs'
    end

    ## next_usd_above_mark
    outs = outs.select do |out|
      if Iro::Strategy::SHORT == pos.long_or_short
        out[:strikePrice] > strategy.next_usd_above_mark + strategy.stock.last
      elsif Iro::Strategy::LONG == pos.long_or_short
        out[:strikePrice] < strategy.stock.last - strategy.next_usd_above_mark
      else
        raise 'zt4 - this cannot happen'
      end
    end
    # puts! outs[0][:strikePrice], 'after calc next_usd_above_mark'
    # puts! outs, 'outs'

    ## next_inner_delta
    outs = outs.select do |out|
      out_delta  = out[:delta].abs rescue 0
      out_delta <= strategy.next_inner_delta
    end
    # puts! outs[0][:strikePrice], 'after calc next_inner_delta'
    # puts! outs, 'outs'

    inner = outs[0]
    outs = outs.select do |out|
      if 'CALL' == pos.put_call
        out[:strikePrice] >= inner[:strikePrice].to_f + strategy.next_spread_amount
      elsif 'PUT' == pos.put_call
        out[:strikePrice] <= inner[:strikePrice].to_f - strategy.next_spread_amount
      end
    end
    outer = outs[0]

    if inner && outer
      o_attrs = {
        expires_on: next_expires_on,
        put_call:   pos.put_call,
        stock_id:   pos.stock_id,
      }
      inner_attrs = o_attrs.merge({
        strike:        inner[:strikePrice],
        begin_price: ( inner[:bid] + inner[:ask] )/2,
        begin_delta:   inner[:delta],
        end_price:   ( inner[:bid] + inner[:ask] )/2,
        end_delta:     inner[:delta],
      })
      outer_attrs = o_attrs.merge({
        strike:        outer[:strikePrice],
        begin_price: ( outer[:bid] + outer[:ask] )/2,
        begin_delta:   outer[:delta],
        end_price:   ( outer[:bid] + outer[:ask] )/2,
        end_delta:     outer[:delta],
      })
      autonxt_attrs = {
        put_call:     pos.put_call,
        status:      'proposed',
        stock:        strategy.stock,
        inner_strike: inner_attrs[:strike],
        inner_attributes: inner_attrs,
        outer_strike: outer_attrs[:strike],
        outer_attributes: outer_attrs,
        begin_on:     Time.now.to_date,
        expires_on:   next_expires_on,
        purse:        purse,
        strategy:     strategy,
        quantity:     pos.quantity,
        autoprev:     pos,
      }
      pos.autonxt ||= Iro::Position.where({
        inner_strike: inner_attrs[:strike],
        outer_strike: outer_attrs[:strike],
        purse:        purse,
        stock:        strategy.stock,
        strategy:     strategy,
      }).first
      pos.autonxt ||= Iro::Position.new(autonxt_attrs)
      pos.autonxt.update(autonxt_attrs)
      pos.autonxt.inner.update(inner_attrs)
      pos.autonxt.outer.update(outer_attrs)

      pos.autonxt.sync
      pos.autonxt.save!
      pos.save
      return pos

    else
      throw 'zmq - should not happen'
    end
  end



  ## ok
  def next_expires_on
    out = expires_on.to_datetime.next_occurring(:monday).next_occurring(:friday)
    if !out.workday?
      out = Time.previous_business_day(out)
    end
    return out.strftime('%Y-%m-%d')
  end

  ## ok
  def self.long
    where( long_or_short: Iro::Strategy::LONG )
  end

  ## ok
  def self.short
    where( long_or_short: Iro::Strategy::SHORT )
  end

  def to_s
    out = "#{stock} (#{q}) #{expires_on.to_datetime.strftime('%b %d')} #{strategy.long_or_short} ["
    if Iro::Strategy::LONG == long_or_short
      if outer&.strike
        out = out + "$#{outer.strike} << "
      end
      out = out + "$#{inner.strike}"
    else
      out = out + "$#{inner.strike}"
      if outer&.strike
        out = out + " >> $#{outer.strike}"
      end
    end
    out += "] "
    return out
  end
end


