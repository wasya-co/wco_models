
class Wco::NewsvideoEventsController < Wco::ApplicationController

  before_action :set_lists, only: [ :edit, :new ]

  def create
    @newsvideo_event = Wco::NewsvideoEvent.new params[:newsvideo_event].permit!
    authorize! :create, @newsvideo_event
    if @newsvideo_event.save
      flash_notice 'Success'
    else
      flash_alert "No luck: #{@newsvideo_event.errors.full_messages.join(',')}."
    end
    redirect_to controller: :newsvideos, method: :index
  end

  def destroy
    @newsvideo_event = Wco::NewsvideoEvent.find params[:id]
    authorize! :destroy, @newsvideo_event
    if @newsvideo_event.delete
      flash[:notice] = "deleted newsvideo_event"
    else
      flash[:alert] = "Cannot delete newsvideo_event: #{@newsvideo_event.errors.messages}"
    end
    redirect_to request.referrer
  end

  def edit
    @newsvideo_event = Wco::NewsvideoEvent.find params[:id]
    authorize! :edit, @newsvideo_event
  end

  def new
    authorize! :create, Wco::NewsvideoEvent
    @newsvideo_event = Wco::NewsvideoEvent.new newsvideo_id: params[:newsvideo_id]
  end

  def update
    @newsvideo_event = Wco::NewsvideoEvent.find params[:id]
    authorize! :update, @newsvideo_event

    if @newsvideo_event.update_attributes params[:newsvideo_event].permit!
      flash_notice 'Success'
    else
      flash_alert "No luck: #{@newsvideo_event.errors.full_messages.join(',')}."
    end
    redirect_to controller: 'newsvideos', action: 'show', id: params[:newsvideo_event][:newsvideo_id]
  end

  ##
  ## private
  ##
  private

  def set_lists
    if params[:newspartial_id]
      partial = Wco::Newspartial.find params[:newspartial_id]
      @newspartials_list = partial.newsvideo.newspartials.list
      @newsvideos_list = []
    else
      @newspartials_list = []
      @newsvideos_list = Wco::Newsvideo.list
    end
  end

end
