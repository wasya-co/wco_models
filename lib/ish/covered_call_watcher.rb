
class ::Ish::CoveredCallWatcher

  def initialize
    @consumer = OAuth::Consumer.new ALLY_CREDS[:consumer_key], ALLY_CREDS[:consumer_secret], { :site => 'https://api.tradeking.com' }
    @access_token = OAuth::AccessToken.new(@consumer, ALLY_CREDS[:access_token], ALLY_CREDS[:access_token_secret])
  end

  def new_order
    ccall = ::Ish::CoveredCall.all.first
    xml = ccall.new_multileg_order_example
    print! xml, 'xml'
    path = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
    # path = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
    response = @access_token.post(path, xml)
    print! response.body, 'response'
  end

  def watch_once
    ccalls = ::Ish::CoveredCall.all
    ccalls.each do |ccall|
      puts! ccall.ticker, 'Watching this ccall'

      path = "/v1/market/ext/quotes.json?symbols=#{ccall.ticker}"
      response = @access_token.get(path, {'Accept' => 'application/json'})
      json = JSON.parse( response.body ).deep_symbolize_keys
      bid = json[:response][:quotes][:quote][:bid].to_f
      ask = json[:response][:quotes][:quote][:ask].to_f
      natural = ( bid + ask ) / 2

      # puts! [ bid, ask ], 'bid, ask'
      # puts! [ ccall.upper_panic_threshold, ccall.lower_panic_threshold ], 'upper/lower panic'

      ## upper panic
      if bid > ccall.upper_panic_threshold
        xml = ccall.rollup_xml access_token=@access_token, natural=natural
        print! xml, 'xml'

        IshManager::ApplicationMailer.ccall_followup_alert( ccall, { action: :rollup } ).deliver_later
        
        ## place order
        path_preview = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
        response = @access_token.post( path_preview, xml )
        print! response.body
        # path_order   = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
        # response = @access_token.post( path_order, xml )
        # print! response.body
      end

      ## lower panic
      if ask < ccall.lower_panic_threshold
        xml = ccall.rolldown_xml access_token=@access_token, natural=natural
        print! xml, 'xml'

        IshManager::ApplicationMailer.ccall_followup_alert( ccall, { action: :rolldown } ).deliver_later
        
        ## place order
        path_preview = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
        response = @access_token.post( path_preview, xml )
        print! response.body
        # path_order   = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
        # response = @access_token.post( path_order, xml )
        # print! response.body
      end

    end
  end

end









