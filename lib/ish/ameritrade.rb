
#
# * make calls every once in a while
# * If the option price dips below a threshold, close the position (create the order to buy back the option)
#

# cron job or service? Well, I've historically done service. Cron is easier tho. The wiring should be for both.

require 'httparty'

module Ish::Ameritrade

  def self.main_fvrr_1
    query_hash = {
      apiKey: '',
      symbol: 'FVRR',
      contractType: 'PUT',
      strike: 200,
      fromDate: '2021-08-20',
      toDate: '2021-08-20',
    }
    response = ::Ish::Ameritrade::Api.get_option_chain(query_hash)

    puts! response, 'ze repsonse'
  end

end

class Ish::Ameritrade::Api
  include ::HTTParty
  base_uri 'api.tdameritrade.com'

  def self.get_option_chain opts

    # validate input
    %i| apiKey symbol contractType strike fromDate toDate |.each do |s|
      if !opts[s]
        raise Ish::InputError.new("invalid input, missing #{s}")
      end
    end

    path = '/v1/marketdata/chains'
    out = self.class.get path, opts
    out
  end

end
