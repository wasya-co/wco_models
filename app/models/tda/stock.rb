
require 'httparty'

class Tda::Stock
  include ::HTTParty
  base_uri 'https://api.schwabapi.com/marketdata/v1'

  ## alias
  def self.get_quote which
    self.get_quotes( which )[0]
  end

  ## tickers = "NVDA,TSLA"
  def self.get_quotes tickers
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'

    path = "/quotes"
    headers = {
      accept:    'application/json',
      Authorization: "Bearer #{profile.schwab_access_token}",
    }
    inns = self.get path, { headers: headers, query: { symbols: tickers } }
    inns = inns.parsed_response
    puts! inns, 'parsed response'

    if [ NilClass, String ].include?( inns.class )
      return []
    end
    inns.each do |k, v|
      inns[k] = v.deep_symbolize_keys
    end
    outs = []
    inns.each do |symbol, _obj|
      obj = _obj[:quote]
      outs.push ::Iro::Priceitem.create!({
        putCall:        'STOCK',
        symbol:          symbol,
        ticker:          symbol,
        bid:             obj[:bidPrice],
        bidSize:         obj[:bidSize],
        ask:             obj[:askPrice],
        askSize:         obj[:askSize],
        last:            obj[:lastPrice],
        openPrice:       obj[:openPrice],
        closePrice:      obj[:closePrice],
        highPrice:       obj[:highPrice],
        lowPrice:        obj[:lowPrice],
        timestamp:       Time.at( obj[:quoteTime]/1000 ),
        totalVolume:     obj[:totalVolume],
        mark:            obj[:mark],
        exchangeName:    obj[:exchangeName],
        volatility:      obj[:volatility],
      })
    end
    return outs
  end

end