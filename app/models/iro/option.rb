
class Iro::Option
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  # include Iro::OptionBlackScholes
  store_in collection: 'iro_options'

  attr_accessor :recompute

  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies
  def ticker; stock.ticker; end

  CALL = 'CALL'
  PUT  = 'PUT'

  field :put_call, type: :string # 'PUT' or 'CALL'
  validates :put_call, presence: true

  field :delta, type: :float

  field :strike, type: :float
  validates :strike, presence: true

  field :expires_on, type: :date
  validates :expires_on, presence: true
  def self.expirations_list full: false, n: 5
    out = [[nil,nil]]
    day = Date.today - 5.days
    n.times do
      next_exp = day.next_occurring(:thursday).next_occurring(:friday)
      if !next_exp.workday?
        next_exp = Time.previous_business_day( next_exp )
      end

      out.push([ next_exp.strftime('%b %e'), next_exp.strftime('%Y-%m-%d') ])
      day = next_exp
    end
    return out
    # [
    #   [ nil, nil ],
    #   [ 'Mar 22', '2024-03-22'.to_date ],
    #   [ 'Mar 28', '2024-03-28'.to_date ],
    #   [ 'Apr 5',  '2024-04-05'.to_date ],
    #   [ 'Mar 12', '2024-03-12'.to_date ],
    #   [ 'Mar 19', '2024-03-19'.to_date ],
    # ]
  end

  field :begin_price, type: :float
  field :begin_delta, type: :float
  field :end_price, type: :float
  field :end_delta, type: :float


  has_one :pos_of_outer, class_name: 'Iro::Position', inverse_of: :outer
  has_one :pos_of_inner, class_name: 'Iro::Position', inverse_of: :inner

  field :last, type: :float

  ## for schwab, eg:
  ## "COST  260306C01030000"
  def symbol
    p_c_ = put_call == 'PUT' ? 'P' : 'C'
    strike_ = format("%08d", (strike.to_f * 1000).round)
    sym = "#{stock.ticker.ljust(6)}#{expires_on.strftime("%y%m%d")}#{p_c_}#{strike_}"
  end

=begin
  symbol = "META  260424P00500000"
=end
  def self.symbol_to_h symbol
    ticker = symbol[0,6].strip
    date_str = symbol[6,6]
    type = symbol[12] == 'P' ? 'PUT' : 'CALL'
    strike_str = symbol[13,8]
    expires_on = Date.strptime(date_str, "%y%m%d")
    strike = strike_str.to_i / 1000.0
    return {
      ticker: ticker,
      strike: strike,
      put_call: type,
      expires_on: expires_on,
    }
  end

  def matches_h h
    if h[:put_call] == put_call &&
       h[:strike] == strike &&
       h[:expires_on] == expires_on
      return true
    else
      return false
    end
  end

  # before_save :sync, if: ->() { !Rails.env.test? } ## do not sync in test
  def sync
    out = Tda::Option.get_quote({
      contractType: put_call,
      strike: strike,
      expirationDate: expires_on.strftime('%Y-%m-%d'),
      ticker: ticker,
    })
    # puts! out, "option sync of `#{self.to_s}`"
    self.end_price = ( out.bid + out.ask ) / 2 rescue 0
    self.end_delta = out.delta ? out.delta : 0.0
    self.save! ## 2026-02-19 this must be present.
  end

  def to_s
    "#{symbol} :: #{expires_on.strftime('%Y-%m-%d')} #{put_call} #{strike}"
  end
end
