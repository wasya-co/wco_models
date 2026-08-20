require 'net/ssh'
require 'pragmatic_segmenter'

class Wco::NewsvideosController < Wco::ApplicationController

  before_action :set_lists
  skip_before_action :verify_authenticity_token, only: [ :add_image_as_overlay, :generate_illustration ]

  def add_image_as_overlay
    duration_sec = 3

    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    workdir    = Rails.root.join('tmp', @newsvideo.id.to_s)
    FileUtils.mkdir_p(workdir)

    w_px = @newsvideo.w_px
    h_px = @newsvideo.h_px
    fps  = @newsvideo.fps

    input = workdir.join("overlay_#{@newsvideo.next_overlay_ms}.jpg")
    URI.open(params[:image_url]) do |src|
      File.binwrite(input, src.read)
    end

    image_path = workdir.join("overlay_#{@newsvideo.next_overlay_ms}_#{w_px}x#{h_px}.jpg")
    cmd = <<~CMD
      magick #{input} \
        -resize "#{w_px}x#{h_px}^" \
        -gravity center \
        -crop "#{w_px}x#{h_px}+0+0" \
        +repage \
        -quality 95 \
        #{image_path}
    CMD
    puts "+++ magick cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    video_path = workdir.join("overlay_#{@newsvideo.next_overlay_ms}.mp4")
    cmd = <<~CMD
      ffmpeg -y \
        -loop 1 \
        -i #{image_path} \
        -t #{duration_sec} \
        -r #{fps} \
        -c:v libx264 \
        -pix_fmt yuv420p \
        -vf "scale=#{w_px}:#{h_px}" \
        #{video_path}
    CMD
    puts "+++ ffmpeg cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    @video = Wco::Video.new name: "#{@newsvideo.title} overlay #{@newsvideo.next_overlay_ms}"
    @video.video = File.open(video_path)
    @video.thumb = File.open(image_path)
    @video.tags = [ Wco::Tag.illustration, Wco::Tag.find_or_create_by({ slug: @newsvideo.slug }) ]
    flag = @video.save
    if !flag
      puts "Could not create video:"
      puts @video.errors.full_messages.join(", ")
    end

    @overlay = Wco::Newsoverlay.new({ duration_ms: duration_sec * 1000,
                                      newsvideo: @newsvideo,
                                      start_at_ms: @newsvideo.next_overlay_ms,
                                      video: @video,
                                   });
    if @overlay.save
      @newsvideo.update( next_overlay_ms: @newsvideo.next_overlay_ms + @overlay.duration_ms )
    else
      puts "Could not create overlay:"
      puts @overlay.errors.full_messages.join(", ")
    end

    render json: { status: :ok }
  end

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

  def generate
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    Rails.env.production? ?
      Wco::NewsvideoGenerateJob.perform_async(@newsvideo.id.to_s) :
      Wco::NewsvideoGenerateJob.perform_sync( @newsvideo.id.to_s)

    render json: { status: :ok, message: 'Scheduled the generation' }
  end

  def generate_all_audio
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    cmd = "cd #{PUPPETEER_ROOT} ; yarn run newsvideo_generate_all_audio #{@newsvideo.id}"
    puts "+++ puppeteer cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    render json: { status: :ok }
  end

  def generate_all_video
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    cmd = "cd #{PUPPETEER_ROOT} ; yarn run newsvideo_generate_all_video #{@newsvideo.id}"
    puts "+++ puppeteer cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    render json: { status: :ok }
  end

  def generate_illustration
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    Rails.env.production? ?
      Wco::NewsvideoIllustrationJob.perform_async(@newsvideo.id.to_s, params[:image_url]) :
      Wco::NewsvideoIllustrationJob.perform_sync( @newsvideo.id.to_s, params[:image_url])

    render json: { status: :ok, message: 'scheduled the run on pc-ai' }
    # redirect_to action: 'show', newsvideo_id: params[:id]
  end

  def index
    authorize! :index, Wco::Newsvideo
    @newsvideos = Wco::Newsvideo.all.order_by( created_at: :desc )
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
    @newsoverlays = @newsvideo.newsoverlays
    @newsvideo_events = @newsvideo.newsvideo_events
    @skip_footer = true

    puts!  @newsvideo_events.to_a, 'zz'
  end

  def split
    @newsvideo = Wco::Newsvideo.unscoped.find params[:id]
    authorize! :edit, @newsvideo

    if Wco::Newspartial.where( newsvideo: @newsvideo).length > 0
      # Wco::Newspartial.where( newsvideo: @newsvideo).each { |n| n.delete }
      flash_alert 'newspartials already exist for this newsvideo - cannot split.'
      redirect_to request.referrer
      return
    end

    @newsvideo.do_split

    flash_notice 'Done spliting the video.'
    redirect_to request.referrer
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
