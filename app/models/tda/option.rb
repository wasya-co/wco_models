
require 'httparty'

=begin
class Schwab
  include HTTParty
  debug_output $stdout
  base_uri 'https://api.schwabapi.com/marketdata/v1'
end
=end

class Tda::Option

  include ::HTTParty
  debug_output $stdout
  # base_uri 'https://api.tdameritrade.com'
  base_uri 'https://api.schwabapi.com/marketdata/v1'


  ##
  ## Get entire chains for a ticker
  ## params: { ticker, force }
  ##
  ## 2024-08-09 :: Continue
  ## 2024-08-21 :: Continue : )
  ##
  def self.get_chains params
    filename = "./data/schwab/#{Time.now.to_date.to_s}-#{params[:ticker]}-chains.json"
    if !params[:force] && File.exists?(filename)
      return JSON.parse File.read filename

    else
      profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
      query = { symbol: params[:ticker] } ## use 'GME' as symbol here even though a symbol is eg 'GME_021023P2.5'
      # puts! query, 'query'

      headers = {
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_access_token]}",
      }
      path = "/chains"
      out = self.get path, {
        headers: headers,
        query: query }
      timestamp = DateTime.parse out.headers['date']
      out = out.parsed_response
      puts! out, 'outs'

      outs = []
      %w| put call |.each do |contractType|
        _out = out["#{contractType}ExpDateMap"]
        _out.each do |date, vs| ## date="2023-02-10:5"
          vs.each do |strike, _v| ## strike="18.5"
            _v = _v[0] ## weird, keep
            # puts! _v, '_v'

            v = {
              putCall: _v['putCall'],
              symbol:  _v['symbol'],
              bid: _v['bid'],
              ask: _v['ask'],
              last: _v['last'],
              totalVolume: _v['totalVolume'],
              openInterest: _v['openInterest'],
              strikePrice: _v['strikePrice'],
              expirationDate: _v['expirationDate'],
            }
            v.each do |k, i|
              if i == 'NaN'
                v[k] = nil
              end
            end

            v[:timestamp] = timestamp
            v[:ticker] = params[:ticker]
            outs.push( v )
          end
        end
      end

      outs.each do |out|
        opi = ::Iro::Priceitem.create( out )
        if !opi.persisted?
          puts! opi.errors.full_messages, "Cannot create PriceItem"
        end
      end

      File.write filename, out.to_json
      return out
    end
  end

  ##
  ## 2023-03-18 _vp_ This is what I should be using to check if a position should be rolled.
  ##
  def self.get_quote params
    OpenStruct.new ::Tda::Option.get_quotes(params)[0]
  end

  ##
  ## params: contractType, strike, expirationDate, ticker
  ##
  ## ow = { contractType: 'PUT', ticker: 'GME', date: '2022-12-09' }
  ## query = {:apikey=>"<>", :toDate=>"2022-12-09", :fromDate=>"2022-12-09", :symbol=>"GME"}
  ##
  ## 2023-02-04 _vp_ :: Too specific, but I want the entire chain, every 1-min
  ## 2023-02-06 _vp_ :: Continue.
  ##
  def self.get_quotes params
    puts! params, 'Tda::Option#get_quotes'

    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    opts = {}

    #
    # Validate input ???
    #
    validOpts = %i| contractType |
    validOpts.each do |s|
      if params[s]
        opts[s] = params[s]
      else
        raise Iro::InputError.new("Invalid input, missing '#{s}'.")
      end
    end
    if params[:expirationDate]
      opts[:fromDate] = opts[:toDate] = params[:expirationDate].to_s[0...10]
    else
      raise Iro::InputError.new("Invalid input, missing 'expirationDate'.")
    end
    if params[:ticker]
      opts[:symbol] = params[:ticker].upcase
    else
      raise Iro::InputError.new("Invalid input, missing 'ticker'.")
    end

    if params[:strike]
      opts[:strike] = params[:strike]
    end

    query = { }.merge opts
    puts! query, 'input opts'

    headers = {
      accept:        'application/json',
      Authorization: "Bearer #{profile[:schwab_access_token]}",
    }

    path = "/chains"
    out = self.get path, {
      # basic_auth: { username: SCHWAB_DATA[:key], password: SCHWAB_DATA[:secret] },
      headers: headers,
      query: query,
    }
    puts! out, 'out'
    timestamp = DateTime.parse out.headers['date']
    out = out.parsed_response.deep_symbolize_keys


    tmp_sym = "#{opts[:contractType].to_s.downcase}ExpDateMap".to_sym
    outs = []
    out = out[tmp_sym]
    out.each do |date, vs|
      vs.each do |strike, _v|
        v = _v[0]
        v = v.except( :lastSize, :optionDeliverablesList, :settlementType,
          :deliverableNote, :pennyPilot, :mini )
        v[:timestamp] = timestamp
        outs.push( v )
      end
    end

    # puts! outs, 'outs'
    return outs
  end


  def self.close_credit_call
  end
  def self.close_long_debit_call_spread
  end
  def self.close_short_debit_put_spread
  end

  def self.get_token
    opts = {
      grant_type: 'authorization_code',
      access_type: 'offline',
      code: ::TD_AMERITRADE[:code],
    }
  end

  def self.create_credit_call outer:, inner:, q:, price:
    query = {
      orderType: "NET_DEBIT",
      session: "NORMAL",
      price: price,
      duration: "DAY",
      orderStrategyType: "SINGLE",
      orderLegCollection: [
        {
          instruction: "BUY_TO_OPEN",
          quantity: q,
          instrument: {
            symbol: outer.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_OPEN",
          quantity: q,
          instrument: {
            symbol: inner.symbol,
            assetType: "OPTION",
          },
        },
      ],
    }
    File.write('tmp/query.json', JSON.pretty_generate( query ))
    puts! query, 'query'

    return

    headers = {
      Authorize: "Bearer #{::TD_AMERITRADE[:access_token]}",
    }

    path = "/v1/accounts/#{::TD_AMERITRADE[:accountId]}/orders"
    puts! path, 'path'
    out = self.post path, { query: query, headers: headers }
    timestamp = DateTime.parse out.headers['date']
    out = out.parsed_response.deep_symbolize_keys
    puts! out, 'created credit call?'
  end
  def self.create_long_debit_call_spread
  end
  def self.create_short_debit_put_spread
  end

  def self.roll_credit_call
  end
  def self.roll_long_debit_call_spread
  end
  def self.roll_short_debit_put_spread
  end


end

##
## From: https://developer.tdameritrade.com/content/place-order-samples
## Buy Limit: Vertical Call Spread
##
=begin
{
  "orderType": "NET_DEBIT",
  "session": "NORMAL",
  "price": "1.20",
  "duration": "DAY",
  "orderStrategyType": "SINGLE",
  "orderLegCollection": [
    {
      "instruction": "BUY_TO_OPEN",
      "quantity": 10,
      "instrument": {
        "symbol": "XYZ_011516C40",
        "assetType": "OPTION"
      }
    },
    {
      "instruction": "SELL_TO_OPEN",
      "quantity": 10,
      "instrument": {
        "symbol": "XYZ_011516C42.5",
        "assetType": "OPTION"
      }
    }
  ]
}
=end



