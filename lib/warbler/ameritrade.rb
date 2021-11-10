
#
# * make calls every once in a while
# * If the option price dips below a threshold, close the position (create the order to buy back the option)
#

# cron job or service? Well, I've historically done service. Cron is easier tho. The wiring should be for both.

# https://developer.tdameritrade.com/option-chains/apis/get/marketdata/chains
# FVRR_082021P200

require 'httparty'

module Ish::Ameritrade

  CONFIG = {
    underlying_downprice_tolerance: 0.14,
  }

  # def self.main_fvrr_1
  #   query_hash = {
  #     apikey: ::TD_AME[:apiKey],
  #     symbol: 'FVRR',
  #     contractType: 'PUT',
  #     strike: 200,
  #     fromDate: '2021-08-20',
  #     toDate: '2021-08-20',
  #   }
  #   response = ::Ish::Ameritrade::Api.get_option_chain(query_hash)
  #   puts! response, 'ze repsonse'
  # end

  ## AKA stop loss
  def self.main_fvrr_2
    # response = ::Ish::Ameritrade::Api.get_quote({ symbol: 'FVRR_082021P200' })

    # @TODO: pass the info on the position in here.
    strike_price = 200

    # What is my risk tolerance here? 14% down movement of the underlying
    response = ::Ish::Ameritrade::Api.get_quote({ symbol: 'FVRR' })
    last_price = response[:lastPrice]
    tolerable_price = ( strike_price * (1-CONFIG[:underlying_downprice_tolerance]) )

    if last_price < tolerable_price
      puts! 'LIMIT TRIGGERED, LETS EXIT' # @TODO: send an email
    end
  end

end

class Ish::Ameritrade::Api
  include ::HTTParty
  base_uri 'https://api.tdameritrade.com'

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

  def self.get_option_chain opts
    # validate input
    %i| apikey symbol contractType strike fromDate toDate |.each do |s|
      if !opts[s]
        raise Ish::InputError.new("invalid input, missing #{s}")
      end
    end

    path = '/v1/marketdata/chains'
    out = self.get path, { query: opts }
    out
  end

end
