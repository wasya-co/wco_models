

class Wco::Api::NewsvideosController < Wco::ApiController

  skip_before_action :decode_jwt
  skip_before_action :verify_authenticity_token
  before_action :decode_simple_api_key

  ##
  ## the other one is used, not this one. Because I don't want to deal with api keys.
  ##
  def generate_illustration
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]

    Rails.env.production? ?
      Wco::NewsvideoIllustrationJob.perform_async(@newsvideo.id.to_s, params[:image_url]) :
      Wco::NewsvideoIllustrationJob.perform_sync( @newsvideo.id.to_s, params[:image_url])

    render json: { status: :ok, message: 'scheduled the run on pc-ai' }
    # redirect_to action: 'show', newsvideo_id: params[:id]
  end

end
