
class ::YahooStockwatcher

  # For: https://query1.finance.yahoo.com/v7/finance/chart/qqq?interval=1d&indicators=quote
  def watch_once

    stocks = Ish::StockWatch.where( :notification_type => :EMAIL )
    # puts! stocks.map(&:ticker), "Watching these stocks"
    stocks.each do |stock|
      # puts! stock.ticker, 'ticker'
      r = HTTParty.get "https://query1.finance.yahoo.com/v7/finance/chart/#{stock.ticker}?interval=1d&indicators=quote", timeout: 10
      r = JSON.parse( r.body ).deep_symbolize_keys
      r = r[:chart][:result][0][:meta][:regularMarketPrice]
      if stock.direction == :ABOVE && r >= stock.price ||
         stock.direction == :BELOW && r <= stock.price
        IshManager::ApplicationMailer.stock_alert( stock ).deliver

        ## actions
        ## exit the position
        # stock.stock_actions.where( :is_active => true ).each do |action|
        #   # @TODO: actions
        # end
        
      end
    end
      
  end

end
