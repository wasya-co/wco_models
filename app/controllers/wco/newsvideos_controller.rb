require 'net/ssh'

class Wco::NewsvideosController < Wco::ApplicationController

  before_action :set_lists

  def create
    params[:newsvideo][:tag_ids]&.delete ''

    @newsvideo = Wco::Newsvideo.new params[:newsvideo].permit!
    authorize! :create, @newsvideo
    @newsvideo.author = current_profile
    if @newsvideo.save
      flash_notice "created newsvideo"
    else
      flash_alert "Cannot create newsvideo: #{@newsvideo.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def destroy
  end

  def edit
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo
  end

  def generate_illustration
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    cmd = " cd /opt/projects/simple_ai_1/src/Stability ; \
      wget --user-agent='Mozilla/5.0' -O input.png #{params[:image_url]} ";

    cmd_1 = " . zenv_stability/bin/activate ; \
      rm -rf out ; \
      python scripts/minimal_run.py ";

    cmd_2 = " ffmpeg -framerate 7 -i out/frames/frame_%04d.png -c:v libx264 -pix_fmt yuv420p out/output.mp4 ; \

      curl -v -X POST '#{WCO_ORIGIN_2}/wco/api/videos/?api_key=#{SIMPLE_API_KEY}&api_secret=#{SIMPLE_API_SECRET}' \
        -H 'Accept: application/json' \
        -F 'video=@out/output.mp4' \
        -F 'thumb=@out/frames/frame_0000.png' \
        -F 'name=#{@newsvideo.title}' \
        -D 'newsvideo_id=#{params[:id]}' ";

    out = `ssh pc-ai " whoami ; pwd ; #{cmd} ; #{cmd_1} ; #{cmd_2} ; "`
    puts! out, 'out'

    render json: { status: :ok } ## _TODO: remove
    # redirect_to action: 'show', newsvideo_id: params[:id]
  end

  def index
    authorize! :index, Wco::Newsvideo
    @newsvideos = Wco::Newsvideo.all
    if params[:deleted]
      @newsvideos = Wco::Newsvideo.unscoped.where( :deleted_at.ne => nil )
    end
    @newsvideos = @newsvideos.page( params[:newsvideos_page] ).per( current_profile.per_page )
  end

  def new
    @newsvideo = Wco::Newsvideo.new
    authorize! :create, @newsvideo
  end

  def show
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :show, @newsvideo
    @newspartials = Wco::Newspartial.where( newsvideo_id: @newsvideo.id.to_s).includes(:video)

    # @config = JSON.parse( @newsvideo.config_json )
    # @duration_ms = @config['vtimes'].last.to_i + @config['vdurations'].last.to_i
  end


  def update
    params[:newsvideo][:tag_ids]&.delete ''

    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :update, @newsvideo
    if @newsvideo.update params[:newsvideo].permit!
      flash_notice "updated newsvideo"
    else
      flash_alert "Cannot update newsvideo: #{@newsvideo.errors.messages}"
    end
    redirect_to action: 'index'
  end

  ##
  ## private
  ##
  private

  def set_lists
    @tags_list = Wco::Tag.list
  end

end
