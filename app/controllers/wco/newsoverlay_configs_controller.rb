

class Wco::NewsoverlayConfigsController < Wco::ApplicationController

  def new
    authorize! :create, Wco::NewsoverlayConfig
    @newsoverlay_config = Wco::NewsoverlayConfig.new video_id: params[:video_id]
    @newsvideos_list = Wco::Newsvideo.list
  end

end
