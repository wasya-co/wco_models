
class Tda::Order

  include ::HTTParty
  debug_output $stdout
  base_uri 'https://api.schwabapi.com/trader/v1'

  STATUS_FILLED   = 'FILLED'
  STATUS_REPLACED = 'REPLACED'
  STATUS_WORKING  = 'WORKING'

  def self.check_status order_id
    profile = Wco::Profile.pi
    results = self.get("/accounts/#{profile.schwab_account_hash}/orders/#{order_id}", {
      headers: {
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_exec_access_token]}",
      },
    })
    puts! results, 'results'
    return results
  end

  ## not used - the hash is stored
  def self.get_account_hash
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    results = self.get("/accounts/accountNumbers", {
      headers: {
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_exec_access_token]}",
      },
    } )
    puts! results, 'results'
  end

  ## obsolete, I don't do covered calls anymore?
  def self.roll_covered_call_q pos
    roll_price = pos.inner.begin_price - pos.autoprev.inner.end_price
    query = {
      orderType: "NET_CREDIT", ## pos.roll_price > 0 ? "NET_CREDIT" : "NET_DEBIT",
      session: "NORMAL",
      duration: "DAY",
      price: ( roll_price + 100 ).to_s, ## _TODO this order will never fill (net credit only)
      orderStrategyType: "SINGLE",
      orderLegCollection: [
        ## close
        {
          instruction: "BUY_TO_CLOSE",
          quantity: pos.q,
          instrument: {
            symbol: pos.autoprev.inner.symbol,
            assetType: "OPTION",
          },
        },

        ## open
        {
          instruction: "SELL_TO_OPEN",
          quantity: pos.q,
          instrument: {
            symbol: pos.inner.symbol,
            assetType: "OPTION",
          },
        },
      ],
    }
    # puts! query, 'query'
    return query
  end

  def self.roll_credit_call_spread_q pos
    query = {
      orderType: pos.roll_price > 0 ? "NET_CREDIT" : "NET_DEBIT",
      session: "NORMAL",
      duration: "DAY",
      price: pos.roll_price.abs.to_s,
      orderStrategyType: "SINGLE",
      orderLegCollection: [
        ## close
        {
          instruction: "BUY_TO_CLOSE",
          quantity: pos.q,
          instrument: {
            symbol: pos.autoprev.inner.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_CLOSE",
          quantity: pos.q,
          instrument: {
            symbol: pos.autoprev.outer.symbol,
            assetType: "OPTION",
          },
        },

        ## open
        {
          instruction: "BUY_TO_OPEN",
          quantity: pos.q,
          instrument: {
            symbol: pos.outer.symbol,
            assetType: "OPTION",
          },
        },
        {
          instruction: "SELL_TO_OPEN",
          quantity: pos.q,
          instrument: {
            symbol: pos.inner.symbol,
            assetType: "OPTION",
          },
        },
      ],
    }
    # puts! query, 'query'
    return query
  end

  def self.place_order query
    puts! query, '#place_order'

    profile = Wco::Profile.pi
    results = self.post("/accounts/#{profile.schwab_account_hash}/orders", {
      headers: {
        'content-type' => 'application/json',
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_exec_access_token]}",
      },
      body: query.to_json,
    })
    order_id = results.headers['location'].split('/').last
    return order_id
  end

end
