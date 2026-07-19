include Math
require 'business_time'

##
## https://www.macrotrends.net/stocks/charts/META/meta-platforms/stock-price-history
##
class ::Iro::Stock
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_stocks'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ nil, 'active', 'inactive' ]
  def self.active
    where( status: STATUS_ACTIVE )
  end
  field :status, default: STATUS_ACTIVE

  field :ticker
  validates :ticker, uniqueness: true, presence: true
  index({ ticker: -1 }, { unique: true })
  def symbol;    ticker;     end
  def symbol= a; ticker = a; end

  field :last, type: :float
  field :options_price_increment, type: :float
  validates :options_price_increment, presence: true

  field :stdev, type: :float

  field :descr, type: :string

  ## for charting:
  field :min,  type: :integer
  field :max,  type: :integer
  field :step, type: :integer, default: 1.0 ## for histograms. I liked 50 bars, that's $1-3 bucket size.

  validate :step_must_fit_range
  def step_must_fit_range
    return if min.blank? || max.blank? || step.blank?

    range = max. - min.to_i
    step_val = step.to_i


    if !((max - min) % step).zero?
      errors.add(:step, "must evenly divide (max-min)/step")
    end
  end



  has_many :positions,  class_name: '::Iro::Position', inverse_of: :stock
  has_many :strategies, class_name: '::Iro::Strategy', inverse_of: :stock
  # has_many :purses,     class_name: '::Iro::Purse',    inverse_of: :stock
  has_many :options,    class_name: '::Iro::Option',   inverse_of: :stock
  has_many :priceitems, inverse_of: :stock

  belongs_to :profile, class_name: 'Wco::Profile', optional: true
  LONG_ONLY     = 'long-only'
  LONG_OR_SHORT = 'long-or-short'
  SHORT_ONLY    = 'short-only'
  field :sentiment, default: LONG_OR_SHORT
  field :sentiment_num, default: 0 # 1 is very long, -1 is very short

  default_scope { order_by({ ticker: :asc }) }

  ## my_find
  def self.f ticker
    self.find_by ticker: ticker
  end

  def to_s
    ticker
  end
  def self.list
    [[nil,nil]] + all.map { |sss| [ sss.ticker, sss.id ] }
  end
  def self.tickers_list
    [[nil,nil]] + all.map { |sss| [ sss.ticker, sss.ticker ] }
  end

=begin
  stock = Iro::Stock.find_by( ticker: 'NVDA' )

  duration = 1.month
  stock.volatility_from_mo

  duration = 1.year
  stock.volatility_from_yr

=end
  field :volatility, type: :float
  field :volatility_annual
  field :volatility_monthly
  field :volatility_daily
  def volatility duration: 1.year, recompute: false
    if self[:volatility]
      if !recompute
        return self[:volatility]
      end
    end
    stock = self
    begin_on = Time.now - duration
    points = ::Iro::Datapoint.where( kind: 'STOCK', symbol: stock.ticker,
      :date.gte => begin_on,
    ).order_by( date: :asc )

    returns = []
    points.each_cons(2) do |prev, curr|
      returns << Math.log(curr.value / prev.value)
    end
    # puts! returns, 'returns'

    mean = returns.sum / returns.size
    variance = returns.sum { |r| (r - mean) ** 2 } / (returns.size - 1)

    daily_vol   = Math.sqrt(variance)
    monthly_vol = daily_vol * Math.sqrt(21)
    annual_vol  = daily_vol * Math.sqrt(252)

    self.update(volatility_annual: annual_vol, volatility_monthly: monthly_vol, volatility_daily: daily_vol)
    annual_vol
  end
  def volatility_old duration: 1.year, recompute: false
    if self[:volatility]
      if !recompute
        return self[:volatility]
      end
    end

    stock = self
    begin_on = Time.now - duration - 1.day
    points = ::Iro::Datapoint.where( kind: 'STOCK', symbol: stock.ticker,
      :date.gte => begin_on,
    ).order_by( date: :asc )

    puts! [points.first.date, points.last.date], "from,to"

    points_p = []
    points.each_with_index do |p, idx|
      next if idx == 0
      prev = points[idx-1]

      out = p.value / prev.value - 1
      points_p.push out
    end
    n = points_p.length

    avg = points_p.reduce(&:+) / n
    _sum_of_sq = []
    points_p.map do |p|
      _sum_of_sq.push( ( p - avg )*( p - avg ) )
    end
    sum_of_sq = _sum_of_sq.reduce( &:+ ) / n

    # n_periods = begin_on.to_date.business_days_until( Date.today )
    out = Math.sqrt( sum_of_sq )*sqrt( n )
    puts! out, 'volatility (adjusted)'
    self.update( volatility: out, volatility_annual: out )
    return out
  end

  def volatility_from_mo
    volatility( duration: 1.month )
  end
  def volatility_from_yr
    volatility( duration: 1.year )
  end
  def stdev recompute: nil
    if !self[:stdev] || recompute
      out = volatility_from_yr
      self[:stdev] = out
      save( validate: false )
      return out
    else
      self[:stdev]
    end
  end

  ## stdev
  ## From: https://stackoverflow.com/questions/19484891/how-do-i-find-the-standard-deviation-in-ruby
  # contents = [1,2,3,4,5,6,7,8,9]
  # n = contents.size             # => 9
  # contents.map!(&:to_f)         # => [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  # mean = contents.reduce(&:+)/n # => 5.0
  # sum_sqr = contents.map {|x| x * x}.reduce(&:+) # => 285.0
  # std_dev = Math.sqrt((sum_sqr - n * mean * mean)/(n-1)) # => 2.7386127875258306

  ##
  ## From: stockdata_org
  ##
  def get_historic_data date_from=nil, date_to=nil
    date_from ||= Time.now - 1.year - 1.week
    date_to   ||= date_from + 180.days
    date_from = date_from.strftime('%Y-%m-%d')
    date_to   = date_to.strftime('%Y-%m-%d')
    puts! [ticker, date_from, date_to], "ticker,date_from,date_to"
    outs = HTTParty.get("https://api.stockdata.org/v1/data/eod?symbols=#{ticker}&date_from=#{date_from}&date_to=#{date_to}&api_token=#{STOCKDATA_ORG_KEY}")
    outs['data'].each do |datum|
      existing = ::Iro::Datapoint.find_by({ symbol: ticker, date: datum['date'].to_date.strftime('%Y-%m-%d') }) rescue nil
      if existing
        print('.')
      else
        ::Iro::Datapoint.create!({ symbol: ticker,
          kind:   ::Iro::Datapoint::KIND_STOCK,
          date:   datum['date'].to_date.strftime('%Y-%m-%d'),
          open:   datum['open'],
          high:   datum['high'],
          low:    datum['low'],
          value:  datum['close'],
          volume: datum['volume'],
        })
        print('^')
      end
    end
  end

  def self.sync
    tickers = Iro::Stock.all.map { |s| s.ticker }.join(',')
    outs = Tda::Stock.get_quotes tickers
    outs.map do |out|
      Iro::Stock.where( ticker: out[:symbol] ).update_all( last: out[:last] )
    end
    puts "+++ Synced stocks."
  end


end
