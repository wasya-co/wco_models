
class Wco::ApiController < ActionController::Base
  layout false

  skip_before_action :verify_authenticity_token

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

  def decode_secret
    if params[:secret].blank? ||
       params[:secret] != AWS_SES_LAMBDA_SECRET

      render status: 400, json: { status: 400, message: "#check_credentials in wco says unauthorized." }
      return
    end
  end

  def decode_simple_api_key
    if params[:api_key].present? &&
       params[:api_secret].present? &&
       params[:api_key]    === Wco::Setting.get('WASYACO_SIMPLE_API_KEY') &&
       params[:api_secret] === Wco::Setting.get('WASYACO_SIMPLE_API_SECRET')

      user = User.find_by({ email: 'piousbox@gmail.com' })
      sign_in user
    else
      throw :unauthorized
    end
  end

end
