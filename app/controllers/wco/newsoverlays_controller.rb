

class Wco::NewsoverlaysController < Wco::ApplicationController

  before_action :set_lists, only: [ :edit, :new ]

  def create
    @newsoverlay = Wco::Newsoverlay.new params[:newsoverlay].permit!
    authorize! :create, @newsoverlay
    if @newsoverlay.save
      flash_notice 'Success'
    else
      flash_alert "No luck: #{@newsoverlay.errors.full_messages.join(',')}."
    end
    redirect_to controller: 'newsvideos', action: 'show', id: params[:newsoverlay][:newsvideo_id]
  end

  def destroy
    @newsoverlay = Wco::Newsoverlay.find params[:id]
    authorize! :destroy, @newsoverlay
    flag = @newsoverlay.delete
    if flag
      flash[:notice] = "deleted newsoverlay"
    else
      flash[:alert] = "Cannot delete newsoverlay: #{@newsoverlay.errors.messages}"
    end
    redirect_to request.referrer
  end

  def edit
    @newsoverlay = Wco::Newsoverlay.find params[:id]
    authorize! :edit, @newsoverlay
  end

  def update
    @newsoverlay = Wco::Newsoverlay.find params[:id]
    authorize! :update, @newsoverlay

    if @newsoverlay.update_attributes params[:newsoverlay].permit!
      flash_notice 'Success'
    else
      flash_alert "No luck: #{@newsoverlay.errors.full_messages.join(',')}."
    end
    redirect_to controller: 'newsvideos', action: 'show', id: params[:newsoverlay][:newsvideo_id]
  end

  def new
    authorize! :create, Wco::Newsoverlay
    video = Wco::Video.find params[:video_id]
    @newsoverlay = Wco::Newsoverlay.new video: video
  end

  ##
  ## private
  ##
  private

  def set_lists
    @newsvideos_list = Wco::Newsvideo.list
  end

end
