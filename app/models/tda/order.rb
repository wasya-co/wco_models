
class Tda::Order

  include ::HTTParty
  debug_output $stdout
  base_uri 'https://api.schwabapi.com/trader/v1'

  def self.get_account_hash
    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    results = self.get("/accounts", {
      headers: {
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_access_token]}",
      },
    } )
    puts! results, 'results'
  end

  def self.roll_short_credit_call_spread pos
    query = {
      orderType: pos.roll_price > 0 ? "NET_CREDIT" : "NET_DEBIT",
      session: "NORMAL",
      price: pos.roll_price,
      duration: "DAY",
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
    puts! query, '@query'

    profile = Wco::Profile.find_by email: 'piousbox@gmail.com'
    account_hash = nil
    results = self.post("/accounts/#{account_hash}/orders", {
      headers: {
        # 'content-type' => 'application/json',
        accept:        'application/json',
        Authorization: "Bearer #{profile[:schwab_access_token]}",
      },
      query: query,
    })
    puts! results, 'results'
  end

end
