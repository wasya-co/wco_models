
class Wco::Api::VideosController < Wco::ApiController

  before_action :decode_simple_api_key

  def create
    # puts! params, 'api videos#create params'
    authorize! :create, Wco::Video
    old_videos = Wco::Video.where({ newspartial_id: params[:newspartial_id] }).map { |v| v.delete }
    puts! old_videos, 'deleted old videos'

    @video = Wco::Video.new({ name: params[:name],
      thumb: params[:thumb],
      video: params[:video],
      newspartial_id: params[:newspartial_id],
    })

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
