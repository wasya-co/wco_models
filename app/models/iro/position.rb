
class Iro::Position
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_positions'

  field :prev_gain_loss_amount, type: :float
  attr_accessor :next_gain_loss_amount
  def prev_gain_loss_amount
    out  = autoprev.outer.end_price - autoprev.inner.end_price
    out += inner.begin_price - outer.begin_price
  end


  STATUS_ACTIVE   = 'active'
  STATUS_CLOSED   = 'closed'
  STATUS_PROPOSED = 'proposed'
  ## one more, 'selected' after proposed?
  STATUS_PENDING  = 'pending' ## 'working'
  STATUSES = [ nil, STATUS_CLOSED, STATUS_ACTIVE, STATUS_PROPOSED, STATUS_PENDING ]
  field :status
  validates :status, presence: true
  scope :active, ->{ where( status: 'active' ) }

  belongs_to :purse, class_name: 'Iro::Purse',    inverse_of: :positions
  index({ purse_id: 1, ticker: 1 })

  belongs_to :stock, class_name: 'Iro::Stock',    inverse_of: :positions
  delegate :ticker, to: :stock

  belongs_to :strategy, class_name: 'Iro::Strategy', inverse_of: :positions
  delegate :long_or_short,   to: :strategy
  delegate :credit_or_debit, to: :strategy

  field :put_call, type: :string
  validates :put_call, presence: true
  def put_call
    self[:put_call] || self.strategy.put_call
  end


  belongs_to :next_strategy, class_name: 'Iro::Strategy', inverse_of: :next_position, optional: true


  belongs_to :prev, class_name: 'Iro::Position', inverse_of: :nxts, optional: true
  belongs_to :autoprev, class_name: 'Iro::Position', inverse_of: :autonxt, optional: true
  ## there are many of these, for viewing on the 'roll' view
  has_many :nxts,     class_name: 'Iro::Position', inverse_of: :prev
  has_one :autonxt, class_name: 'Iro::Position', inverse_of: :autoprev

  ## Options

  belongs_to :inner, class_name: 'Iro::Option', inverse_of: :inner
  validates_associated :inner

  belongs_to :outer, class_name: 'Iro::Option', inverse_of: :outer
  validates_associated :outer

  accepts_nested_attributes_for :inner, :outer

  field     :outer_strike, type: :float
  # validates :outer_strike, presence: true

  field     :inner_strike, type: :float
  # validates :inner_strike, presence: true

  field :expires_on
  validates :expires_on, presence: true

  field :quantity, type: :integer
  validates :quantity, presence: true
  def q; quantity; end

  field :begin_on

  field :end_on

  def begin_delta
    strategy.send("begin_delta_#{strategy.kind}", self)
  end
  def end_delta
    strategy.send("end_delta_#{strategy.kind}", self)
  end

  def breakeven
    strategy.send("breakeven_#{strategy.kind}", self)
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

  def net_percent
    net_amount / max_gain
  end
  def net_amount # each
    self.send("net_amount_#{strategy.kind}")
  end
  ## 2025-10-14 tested
  def net_amount_long_credit_put_spread ## each
    inner.begin_price - outer.begin_price + outer.end_price - inner.end_price
  end

  def max_gain # each
    strategy.send("max_gain_#{strategy.kind}", self)
  end
  def max_loss # each
    strategy.send("max_loss_#{strategy.kind}", self)
  end


  def sync
    inner.sync
    outer.sync
  end


  ##
  ## decisions
  ##

  field :next_reasons, type: :array, default: []
  field :rollp, type: :float

  ## should_roll?
  def calc_rollp
    self.next_reasons = []
    # self.next_symbol  = nil
    # self.next_delta   = nil

    out = strategy.send( "calc_rollp_#{strategy.kind}", self )

    self.rollp = out[0]
    self.next_reasons.push out[1]
    save
  end

  def calc_nxt
    pos = self

    ## 7 days ahead - not configurable
    params = {
      contractType: pos.put_call,
      expirationDate: next_expires_on,
      ticker: ticker,
    }
    # puts! params, '#calc_nxt'
    outs = Tda::Option.get_quotes(params)
    # puts! outs, 'outs'
    outs_bk = outs.dup

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
    puts! outs[0][:strikePrice], 'after calc next_inner_strike'
    # puts! outs, 'outs'

    ## next_buffer_above_water
    outs = outs.select do |out|
      if Iro::Strategy::SHORT == pos.long_or_short
        out[:strikePrice] > strategy.next_buffer_above_water + strategy.stock.last
      elsif Iro::Strategy::LONG == pos.long_or_short
        out[:strikePrice] < strategy.stock.last - strategy.next_buffer_above_water
      else
        raise 'zt4 - this cannot happen'
      end
    end
    puts! outs[0][:strikePrice], 'after calc next_buffer_above_water'
    puts! outs, 'outs'

    ## next_inner_delta
    outs = outs.select do |out|
      if 'CALL' == pos.put_call
        out_delta  = out[:delta] rescue 1
        out_delta <= strategy.next_inner_delta
      elsif 'PUT' == pos.put_call
        out_delta  = out[:delta] rescue 0
        out_delta <= strategy.next_inner_delta
      else
        raise 'zt5 - this cannot happen'
      end
    end
    puts! outs[0][:strikePrice], 'after calc next_inner_delta'
    puts! outs, 'outs'

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
      inner_ = Iro::Option.new(o_attrs.merge({
        strike:        inner[:strikePrice],
        begin_price: ( inner[:bid] + inner[:ask] )/2,
        begin_delta:   inner[:delta],
        end_price:   ( inner[:bid] + inner[:ask] )/2,
        end_delta:     inner[:delta],
      }))
      outer_ = Iro::Option.new(o_attrs.merge({
        strike:        outer[:strikePrice],
        begin_price: ( outer[:bid] + outer[:ask] )/2,
        begin_delta:   outer[:delta],
        end_price:   ( outer[:bid] + outer[:ask] )/2,
        end_delta:     outer[:delta],
      }))
      pos.autonxt ||= Iro::Position.new
      pos.autonxt.update({
        prev_gain_loss_amount: 'a',
        put_call:     pos.put_call,
        status:      'proposed',
        stock:        strategy.stock,
        inner:        inner_,
        outer:        outer_,
        inner_strike: inner_.strike,
        outer_strike: outer_.strike,
        begin_on:     Time.now.to_date,
        expires_on:   next_expires_on,
        purse:        purse,
        strategy:     strategy,
        quantity:     1,
        autoprev:     pos,
      })

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
      if outer.strike
        out = out + "$#{outer.strike}->"
      end
      out = out + "$#{inner.strike}"
    else
      out = out + "$#{inner.strike}"
      if outer.strike
        out = out + "<-$#{outer.strike}"
      end
    end
    out += "] "
    return out
  end
end


