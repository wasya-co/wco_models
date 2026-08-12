
class Wco::Api::NewsvideosController < Wco::ApiController

  before_action :decode_simple_api_key

  ##
  ## 2026-08-12 _vp_ continue
  ##
  def generate
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]

    Rails.env.production? ?
      Wco::NewsvideoGenerateJob.perform_async(@newsvideo.id.to_s) :
      Wco::NewsvideoGenerateJob.perform_sync( @newsvideo.id.to_s)

    render json: { status: :ok, message: 'Scheduled the generation' }
  end

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

  def show
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
  end

end
