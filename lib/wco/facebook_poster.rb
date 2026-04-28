
class Wco::FacebookPoster
  include HTTParty
  base_uri 'https://graph.facebook.com/v19.0'

  def initialize
    @page_id = ::FB_PAGE_ID # Rails.application.credentials.dig(:facebook, :page_id)
    @access_token = ::FB_ACCESS_TOKEN # Rails.application.credentials.dig(:facebook, :access_token)
  end

  def post(message)
    self.class.post("/#{@page_id}/feed", body: {
      message: message,
      access_token: @access_token
    })
  end
end
