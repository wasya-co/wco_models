
class Wco::ApiController < ActionController::Base
  layout false

  before_action :decode_jwt

  ##
  ## private
  ##
  private

  def decode_jwt
    out = JWT.decode params[:jwt_token], nil, false
    email = out[0]['email']
    user = User.find_by({ email: email })
    sign_in user
  end

  def decode_simple_api_key
    if params[:api_key] === SIMPLE_API_KEY &&
       params[:api_secret] === SIMPLE_API_SECRET
      user = User.find_by({ email: 'piousbox@gmail.com' })
      sign_in user
    end
  end

end
