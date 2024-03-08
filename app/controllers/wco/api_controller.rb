
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

end
