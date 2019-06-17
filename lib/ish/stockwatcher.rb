
class Stockwatcher

  def initialize
  end

  # every minute, for alphavantage.co
  def watch
    stocks = Ish::StockWatch.where( :notification_type => :EMAIL )
    puts! stocks.map(&:ticker), "Watching these stocks:"
    stocks.each do |stock|
      r = HTTParty.get "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=#{stock.ticker}&interval=1min&apikey=X1C5GGH5MZSXMF3O", timeout: 10
      r2 = JSON.parse( r.body )['Time Series (1min)']
      r3 = r2[r2.keys.first]['4. close'].to_f
      if stock.direction == :ABOVE && r3 >= stock.price ||
         stock.direction == :BELOW && r3 <= stock.price
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
