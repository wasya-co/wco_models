
require 'httparty'

#
# * make calls every once in a while
# * If the option price dips below a threshold, close the position (create the order to buy back the option)
#

# cron job or service? Well, I've historically done service. Cron is easier tho. The wiring should be for both.

# https://developer.tdameritrade.com/option-chains/apis/get/marketdata/chains
# FVRR_082021P200


module Warbler::Ameritrade

  CONFIG = {
    underlying_downprice_tolerance: 0.14,
  }

  ## AKA stop loss
  def self.main_fvrr_2

    # @TODO: pass the info on the position in here.
    strike_price = 200

    # What is my risk tolerance here? 14% down movement of the underlying
    response = ::Warbler::Ameritrade::Api.get_quote({ symbol: 'FVRR' })
    last_price = response[:lastPrice]
    tolerable_price = ( strike_price * (1-CONFIG[:underlying_downprice_tolerance]) )

    if last_price < tolerable_price
      puts! 'LIMIT TRIGGERED, LETS EXIT' # @TODO: send an email
    end
  end

end

class ::Warbler::Ameritrade::Api
  include ::HTTParty
  base_uri 'https://api.tdameritrade.com'
  PUT = 'PUT'
  CALL = 'CALL'

  def self.get_quote opts
    # validate input
    %i| symbol |.each do |s|
      if !opts[s]
        raise Ish::InputError.new("invalid input, missing #{s}")
      end
    end

    path = "/v1/marketdata/#{opts[:symbol]}/quotes"
    out = self.get path, { query: { apikey: ::TD_AME[:apiKey] } }
    out = out.parsed_response[out.parsed_response.keys[0]].symbolize_keys
    out
  end

  def self.get_option _opts
    opts = {}

    # validate input
    validOpts = %i| contractType strike symbol|
    validOpts.each do |s|
      if _opts[s]
        opts[s] = _opts[s]
      else
        raise Ish::InputError.new("invalid input, missing #{s}")
      end
    end
    if _opts[:date]
      opts[:fromDate] = opts[:toDate] = _opts[:date]
    else
      raise Ish::InputError.new("invalid input, missing 'date'")
    end

    query = { apikey: ::TD_AME[:apiKey], strikeCount: 1 }.merge opts
    path = "/v1/marketdata/chains"
    out = self.get path, { query: query }
    out = out.parsed_response.deep_symbolize_keys
    tmp_sym = "#{opts[:contractType].to_s.downcase}ExpDateMap".to_sym
    out[tmp_sym].first[1].first[1][0]
  end

end
