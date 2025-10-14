
class Iro::Strategy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'iro_strategies'

  # field :slug
  # validates :slug, presence: true, uniqueness: true

  field :description

  LONG  = 'long'
  SHORT = 'short'
  field     :long_or_short, type: :string
  validates :long_or_short, presence: true

  CREDIT = 'credit'
  DEBIT  = 'debit'
  field     :credit_or_debit, type: :string, default: 'credit'
  validates :credit_or_debit, presence: true


  has_many :positions,     class_name: 'Iro::Position', inverse_of: :strategy,     dependent: :destroy
  has_one  :next_position, class_name: 'Iro::Position', inverse_of: :next_strategy ## _TODO: makes no sense...
  belongs_to :stock,       class_name: 'Iro::Stock',    inverse_of: :strategies
  # has_and_belongs_to_many :purses, class_name: 'Iro::Purse',    inverse_of: :strategies

  KIND_COVERED_CALL             = 'covered_call'
  KIND_IRON_CONDOR              = 'iron_condor'
  KIND_LONG_CREDIT_PUT_SPREAD   = 'long_credit_put_spread'
  KIND_LONG_DEBIT_CALL_SPREAD   = 'long_debit_call_spread'
  KIND_SHORT_CREDIT_CALL_SPREAD = 'short_credit_call_spread'
  KIND_SHORT_DEBIT_PUT_SPREAD   = 'short_debit_put_spread'
  ## these are too simple and deprecated:
  KIND_SPREAD = 'spread' ## @deprecated, be specific
  KIND_WHEEL  = 'wheel'  ## @deprecated, be specific
  KINDS = [ nil,
    KIND_COVERED_CALL,
    KIND_IRON_CONDOR,
    KIND_LONG_CREDIT_PUT_SPREAD,
    KIND_LONG_DEBIT_CALL_SPREAD,
    KIND_SHORT_CREDIT_CALL_SPREAD,
    KIND_SHORT_DEBIT_PUT_SPREAD,
    KIND_SPREAD,
    KIND_WHEEL,
  ];
  field :kind

  def put_call
    case kind
    when Iro::Strategy::KIND_LONG_CREDIT_PUT_SPREAD
      put_call = 'PUT'
    when Iro::Strategy::KIND_LONG_DEBIT_CALL_SPREAD
      put_call = 'CALL'
    when Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD
      put_call = 'CALL'
    when Iro::Strategy::KIND_SHORT_DEBIT_PUT_SPREAD
      put_call = 'PUT'
    when Iro::Strategy::KIND_COVERED_CALL
      put_call = 'CALL'
    when Iro::Strategy::KIND_SPREAD
      if credit_or_debit == CREDIT
        if long_or_short == LONG
          'PUT'
        elsif long_or_short == SHORT
          'CALL'
        else
          throw 'zq5 - should never happen'
        end
      else
        throw 'zq6 - debit spreads are not implemented'
      end
    else
      # put_call = 'zq9-ERROR'
      throw 'zq9 - this should never happen'
    end
  end

  field :buffer_above_water, type: :float
  field :threshold_pos_delta,              type: :float # best-case scenario: roll b/c markets are going my way
  field :threshold_neg_delta, type: :float # nightmare scenario: defensively rolling
  field :threshold_netp,               type: :float
  field :threshold_dte,                type: :integer, default: 1

  field :next_inner_delta,        type: :float
  field :next_inner_strike,       type: :float
  field :next_outer_delta,        type: :float
  field :next_outer_strike,       type: :float
  field :next_spread_amount,      type: :float # e.g. $20 for a $2000 NVDA spread
  field :next_buffer_above_water, type: :float


  def begin_delta_wheel p
    p.inner.begin_delta
  end
  def begin_delta_spread p
    p.inner.begin_delta - p.outer.begin_delta
  end
  def begin_delta_long_credit_put_spread p
    begin_delta_spread p
  end


  def breakeven_covered_call p
    p.inner.strike + p.inner.begin_price
  end
  def breakeven_long_debit_call_spread p
    p.inner.strike - p.max_gain
  end
  alias_method :breakeven_short_debit_put_spread, :breakeven_long_debit_call_spread


  def end_delta_wheel p
    p.inner.end_delta
  end
  def end_delta_spread p
    p.inner.end_delta - p.outer.end_delta
  end
  def end_delta_long_credit_put_spread p
    end_delta_spread p
  end


  def max_gain_covered_call p
    p.inner.begin_price * 100 - 0.66 # @TODO: is this *100 really?
  end
  def max_gain_long_credit_put_spread p
    ## 100 * disallowed for gameui
    p.inner.begin_price - p.outer.begin_price
  end
  def max_gain_long_debit_call_spread p
    ## 100 * disallowed for gameui
    ( p.inner.strike - p.outer.strike - p.outer.begin_price + p.inner.begin_price ) # - 2*0.66
  end
  def max_gain_short_credit_call_spread p
    p.inner.begin_price - p.outer.begin_price
  end
  def max_gain_short_debit_put_spread p
    ## 100 * disallowed for gameui
    ( p.outer.strike - p.inner.strike - p.outer.begin_price + p.inner.begin_price ) # - 2*0.66
  end
  def max_gain_spread p
    ## 100 * disallowed for gameui
    ( p.outer.strike - p.inner.strike ).abs - p.outer.begin_price + p.inner.begin_price # - 2*0.66
  end
  def max_gain_wheel p
    p.inner.begin_price * 100 - 0.66 # @TODO: is this *100 really?
  end


  def max_loss_covered_call p
    p.inner.begin_price*10 # just suppose 10,000%
  end
  def max_loss_long_credit_put_spread p
    out = p.inner.strike - p.outer.strike
  end
  def max_loss_long_debit_call_spread p
    out = p.outer.strike - p.inner.strike
  end
  def max_loss_short_debit_put_spread p # different
    out = p.inner.strike - p.outer.strike
  end
  def max_loss_short_credit_call_spread p
    out = p.outer.strike - p.inner.strike
  end
  def max_loss_spread p
    ( p.outer.strike - p.inner.strike ).abs
  end
  def max_loss_wheel p
    p.inner.begin_price*10 # just suppose 10,000%
  end



  def net_amount_spread p
    p.inner.begin_price - p.inner.end_price
  end
  def net_amount_long_credit_put_spread p
    p.inner.begin_price - p.inner.end_price
  end


  ## 2024-05-09 @TODO
  ## 2025-10-11 _TODO
  def next_inner_strike_on expires_on
    outs = ::Tda::Option.get_quotes({
      contractType: put_call,
      expirationDate: expires_on,
      ticker: stock.ticker,
    })
    puts! outs, 'next_inner_strike_on -> outs'
  end



  ##
  ## decisions
  ##

  def calc_rollp_covered_call p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 1
      return [ 0.99, '0 DTE, must exit' ]
    end

    if ( stock.last - buffer_above_water ) < p.inner.strike
      return [ 0.98, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [p.inner.strike + buffer_above_water - stock.last]} " +
          "below #{'%.2f' % [p.inner.strike + buffer_above_water]} water" ]
    end

    if p.inner.end_delta < threshold_pos_delta
      return [ 0.61, "Delta #{p.inner.end_delta} is lower than #{threshold_pos_delta} threshold." ]
    end

    if 1 - p.inner.end_price/p.inner.begin_price > threshold_netp
      return [ 0.51, "made enough #{'%.02f' % [(1.0 - p.inner.end_price/p.inner.begin_price )*100]}% profit." ]
    end

    return [ 0.33, '-' ]
  end

  ## @TODO
  def calc_rollp_long_debit_call_spread p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 1
      return [ 0.99, '0 DTE, must exit' ]
    end
    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 2
      return [ 0.99, '1 DTE, must exit' ]
    end

    if ( stock.last - buffer_above_water ) < p.inner.strike
      return [ 0.95, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [stock.last - p.inner.strike - buffer_above_water]} " +
          "below #{'%.2f' % [p.inner.strike + buffer_above_water]} water" ]
    end

    if p.inner.end_delta < threshold_pos_delta
      return [ 0.79, "Delta #{p.inner.end_delta} is lower than #{threshold_pos_delta} threshold." ]
    end

    if 1 - p.inner.end_price/p.inner.begin_price > threshold_netp
      return [ 0.51, "made enough #{'%.02f' % [(1.0 - p.inner.end_price/p.inner.begin_price )*100]}% profit^" ]
    end

    return [ 0.33, '-' ]
  end

  ## 2025-10-12 _TODO
  def calc_rollp_long_credit_put_spread p
    # puts! p, '#calc_rollp_long_credit_put_spread'
    # puts! p.inner, 'p.inner'
    puts! stock, 'stock'
    puts! attributes, 'strategy attributes'

    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 1
      return [ 0.99, '0 DTE, must exit' ]
    end
    if ( p.expires_on.to_date - Time.now.to_date ).to_i < 2
      return [ 0.99, '1 DTE, must exit' ]
    end

    if ( stock.last - buffer_above_water ) < p.inner.strike
      return [ 0.95, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [stock.last - p.inner.strike - buffer_above_water]} " +
          "below #{'%.2f' % [p.inner.strike + buffer_above_water]} water" ]
    end

    if p.inner.end_delta < threshold_pos_delta
      return [ 0.79, "Delta #{p.inner.end_delta} is lower than #{threshold_pos_delta} threshold." ]
    end

    if 1 - p.inner.end_price/p.inner.begin_price > threshold_netp
      return [ 0.51, "made enough #{'%.02f' % [(1.0 - p.inner.end_price/p.inner.begin_price )*100]}% profit^" ]
    end

    return [ 0.33, '-' ]
  end

  ## @TODO
  def calc_rollp_short_debit_put_spread p

    if ( p.expires_on.to_date - Time.now.to_date ).to_i <= min_dte
      return [ 0.99, "< #{min_dte}DTE, must exit" ]
    end

    if stock.last + buffer_above_water > p.inner.strike
      return [ 0.98, "Last #{'%.2f' % stock.last} is " +
          "#{'%.2f' % [stock.last + buffer_above_water - p.inner.strike]} " +
          "above #{'%.2f' % [p.inner.strike - buffer_above_water]} water" ]
    end

    if p.inner.end_delta.abs < threshold_pos_delta.abs
      return [ 0.79, "Delta #{p.inner.end_delta} is lower than #{threshold_pos_delta} threshold." ]
    end

    if p.net_percent > threshold_netp
      return [ 0.51, "made enough #{'%.0f' % [p.net_percent*100]}% > #{"%.2f" % [threshold_netp*100]}% profit," ]
    end

    return [ 0.33, '-' ]
  end


  ## scopes

  def self.for_ticker ticker
    where( ticker: ticker )
  end


  def slug
    "#{long_or_short} #{credit_or_debit} #{kind} #{stock}"
  end
  def to_s
    slug
  end
  def self.list long_or_short = nil
    these = long_or_short ? where( long_or_short: long_or_short ) : all
    [[nil,nil]] + these.map { |ttt| [ ttt, ttt.id ] }
  end
end

