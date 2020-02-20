
# result = @access_token.get('/v1/accounts.json', {'Accept' => 'application/json'})
# json = JSON.parse result.body


class ::Ish::IronCondorWatcher

  def initialize
    @consumer = OAuth::Consumer.new ALLY_CREDS[:consumer_key], ALLY_CREDS[:consumer_secret], { :site => 'https://api.tradeking.com' }
    @access_token = OAuth::AccessToken.new(@consumer, ALLY_CREDS[:access_token], ALLY_CREDS[:access_token_secret])
  end


  def new_order
    condor = ::Ish::IronCondor.all.first
    xml = condor.new_multileg_order_example
    print! xml, 'xml'
    path = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
    # path = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
    response = @access_token.post(path, xml)
    print! response.body, 'response'
  end

  def watch_once
    condors = ::Ish::IronCondor.all_filled
    condors.each do |condor|
      puts! condor.ticker, 'Watching this condor'

      path = "/v1/market/ext/quotes.json?symbols=#{condor.ticker}"
      response = @access_token.get(path, {'Accept' => 'application/json'})
      json = JSON.parse( response.body ).deep_symbolize_keys
      bid = json[:response][:quotes][:quote][:bid].to_f
      ask = json[:response][:quotes][:quote][:ask].to_f
      natural = ( bid + ask ) / 2

      puts! [ bid, ask ], 'bid, ask'
      puts! [ condor.upper_panic_threshold, condor.lower_panic_threshold ], 'upper/lower panic'

      ## upper panic
      if bid > condor.upper_panic_threshold
        xml = condor.rollup_xml access_token=@access_token, natural=natural
        print! xml, 'xml'

        IshManager::ApplicationMailer.condor_followup_alert( condor, { action: :rollup } ).deliver_later
        
        ## place order
        path_preview = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
        response = @access_token.post( path_preview, xml )
        print! response.body
        # path_order   = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
        # response = @access_token.post( path_order, xml )
        # print! response.body
      end

      ## lower panic
      if ask < condor.lower_panic_threshold
        xml = condor.rolldown_xml access_token=@access_token, natural=natural
        print! xml, 'xml'

        IshManager::ApplicationMailer.condor_followup_alert( condor, { action: :rolldown } ).deliver_later
        
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









