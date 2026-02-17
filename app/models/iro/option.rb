
class Iro::Option
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  # include Iro::OptionBlackScholes
  store_in collection: 'iro_options'

  attr_accessor :recompute

  belongs_to :stock, class_name: 'Iro::Stock', inverse_of: :strategies
  def ticker; stock.ticker; end
  # field :ticker
  # validates :ticker, presence: true

  CALL = 'CALL'
  PUT  = 'PUT'

  field :symbol
  ## each option can be a leg in a position, no uniqueness
  # validates :symbol, uniqueness: true, presence: true

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


  has_one :outer, class_name: 'Iro::Position', inverse_of: :outer
  has_one :inner, class_name: 'Iro::Position', inverse_of: :inner

  field :last, type: :float

  ## for TDA
  def symbol
    if !self[:symbol]
      p_c_ = put_call == 'PUT' ? 'P' : 'C'
      strike_ = strike.to_i == strike ? strike.to_i : strike
      sym = "#{stock.ticker}_#{expires_on.strftime("%m%d%y")}#{p_c_}#{strike_}" # XYZ_011819P45
      self[:symbol] = sym
      save
    end
    self[:symbol]
  end

  before_save :sync, if: ->() { !Rails.env.test? } ## do not sync in test
  def sync
    out = Tda::Option.get_quote({
      contractType: put_call,
      strike: strike,
      expirationDate: expires_on.strftime('%Y-%m-%d'),
      ticker: ticker,
    })
    puts! out, 'option sync'
    self.end_price = ( out.bid + out.ask ) / 2 rescue 0
    self.end_delta = out.delta if out.delta
    # self.save
  end

  def self.max_pain hash
    outs = {}

    %w| put call |.each do |contractType|
      dates = hash["#{contractType}ExpDateMap"]
      dates.each do |_date, strikes| ## _date="2023-02-10:5"
        date = _date.split(':')[0].to_date.to_s
        outs[date] ||= {
          'all'  => {},
          'call' => {},
          'put'  => {},
          'summary' => {},
        }

        strikes.each do |_strike, _v| ## _strike="18.5"
          strike = _strike.to_f

          ## calls
          mem_c = 0
          strikes.keys.reverse.each do |_key|
            if _key == _strike
              break
            end
            key = _key.to_f
            tmp = hash["callExpDateMap"][_date][_key][0]['openInterest'] * ( key - strike )
            mem_c += tmp
          end
          outs[date]['call'][_strike] = mem_c

          ## puts
          mem_p = 0
          strikes.keys.each do |_key|
            if _key == _strike
              break
            end
            key = _key.to_f
            tmp = hash["putExpDateMap"][_date][_key][0]['openInterest'] * ( strike - key )
            mem_p += tmp
          end
          outs[date]['put'][_strike] = mem_p
          outs[date]['all'][_strike] = mem_c + mem_p

        end
      end
    end

    ## compute summary
    outs.each do |date, types|
      all = types['all']
      outs[date]['summary'] = { 'value' => all.keys[0] }
      all.each do |strike, amount|
        if amount < all[ outs[date]['summary']['value'] ]
          outs[date]['summary']['value'] = strike
        end
      end
    end

    return outs
  end


end
