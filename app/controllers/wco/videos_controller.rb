
class Wco::VideosController < Wco::ApplicationController

  # before_action :set_lists

  # Alphabetized : )

  def create
    @video = Wco::Video.new params[:video].permit!
    authorize! :create, @video

    if @video.save
      flash[:notice] = 'Success'
      redirect_to videos_path
    else
      flash[:alert] = 'No luck'
      render :action => 'new'
    end
  end

  def destroy
    @video = Wco::Video.find params[:id]
    authorize! :destroy, @video
    flag = @video.delete
    if flag
      flash[:notice] = "deleted video"
    else
      flash[:alert] = "Cannot delete video: #{@video.errors.messages}"
    end
    redirect_to :action => 'index'
  end

  def edit
    @video = Wco::Video.unscoped.find params[:id]
    authorize! :edit, @video
  end

  def index
    authorize! :index, Wco::Video.new
    @videos = Wco::Video.order_by( :created_at => :desc )

    if params[:q]
      @videos = @videos.where({ :name => /#{params[:q]}/i })
    end

    @videos = @videos.page( params[:videos_page] ).per( 9 )

    respond_to do |format|
      format.html do
        render '_index'
      end
      format.json do
        render :json => @videos
      end
    end
  end

  def show
    if params[:youtube_id].present?
      @video = Wco::Video.unscoped.where( :youtube_id => params[:youtube_id] ).first
    end
    @video ||= Wco::Video.unscoped.find params[:id]
    authorize! :show, @video

    respond_to do |format|
      format.html
      format.json do
        render :json => @video
      end
    end
  end

  def new
    @video = Wco::Video.new
    authorize! :new, @video
  end

  def update
    @video = Wco::Video.unscoped.find params[:id]
    authorize! :update, @video

    # old_shared_profile_ids = @video.shared_profile_ids
    # if params[:video][:shared_profiles].present?
    #   params[:video][:shared_profiles].delete('')
    # end
    # params[:video][:shared_profile_ids] = params[:video][:shared_profiles]
    # params[:video].delete :shared_profiles

    @video.update params[:video].permit!
    if @video.save

      # if params[:video][:shared_profile_ids].present?
      #   new_shared_profiles = Ish::UserProfile.find( params[:video][:shared_profile_ids]
      #     ).select { |p| !old_shared_profile_ids.include?( p.id ) }
      #   ::IshManager::ApplicationMailer.shared_video( new_shared_profiles, @video ).deliver
      # end

      flash[:notice] = 'Success.'
      redirect_to video_path(@video)
    else
      flash[:alert] = "No luck: #{@video.errors.full_messages.joing(', ')}"
      render :edit
    end
  end

end
