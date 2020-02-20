
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
    condors = ::Ish::IronCondor.all
    condors.each do |condor|

      path = "/v1/market/ext/quotes.json?symbols=#{condor.ticker}"
      response = @access_token.get(path, {'Accept' => 'application/json'})
      json = JSON.parse response.body
      json.deep_symbolize_keys!
      bid = json[:response][:quotes][:quote][:bid].to_f
      ask = json[:response][:quotes][:quote][:ask].to_f
      natural = ( bid + ask ) / 2

      ## upper panic
      if bid > condor.upper_panic_theshold
        
        xml = condor.rollup_tmpl access_token=@access_token, natural=natural
        puts! xml, 'xml'

        IshManager::ApplicationMailer.condor_rollup_alert( condor ).deliver
        
        ## place order
        # path_order = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders.xml"
        path_order = "/v1/accounts/#{ALLY_CREDS[:account_id]}/orders/preview.xml"
        response = @access_token.post(path_order, {'Accept' => 'application/json'})
        json_order = JSON.parse response.body
        puts! json_order, 'json_order'
      end

      ## lower panic
      if ask < condor.lower_panil_theshold
        # followup, roll down
      end

    end
  end

end









