
class Wco::Api::VideosController < Wco::ApiController

  skip_before_action :decode_jwt
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :decode_simple_api_key

  def create
    # puts! params, 'api videos#create params'

    @video = Wco::Video.new({ name: params[:name],
      thumb: params[:thumb],
      video: params[:video],
      newspartial_id: params[:newspartial_id],
    })
    authorize! :create, @video

    if @video.save
      puts! @video, 'Created @video.'
      flash[:notice] = 'Success'
      render json: { status: :ok, message: @video.attributes }
    else
      flash[:alert] = 'No luck'
      render json: { status: :not_ok, message: 'Could not create video.' }
    end
  end

end
