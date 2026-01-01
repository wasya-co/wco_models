require 'net/ssh'
require 'pragmatic_segmenter'

class Wco::NewsvideosController < Wco::ApplicationController

  before_action :set_lists
  skip_before_action :verify_authenticity_token, only: [ :generate_illustration ]

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


    ## put together config
    # cmd = "cd #{Rails.root.join('tmp')} ; mkdir -p #{@newsvideo.id} ; cd #{@newsvideo.id} ; rm -f videolist.txt audiolist.txt ; "
    # @newsvideo.newspartials.each_with_index do |part, idx|
    #   cmd = "#{cmd} echo \"file 'newspartial_#{idx}.mp4' \" >> videolist.txt ; "
    #   cmd = "#{cmd} echo \"file 'newspartial_#{idx}.wav' \" >> audiolist.txt ; "
    #   cmd = "#{cmd} ffmpeg -i newspartial_#{idx}.webm newspartial_#{idx}.mp4 ; "
    # end
    # puts! cmd, 'cmd'
    # out = `#{cmd}`
    # puts! out, 'out'

    ## get base files locally
    # cmd = "cd #{Rails.root.join('tmp', @newsvideo.id)} ; "
    # @newsvideo.newspartials.each_with_index do |part, idx|
    #   cmd = "#{cmd} wget -O newspartial_#{idx}.webm #{part.video.video.url} ; "
    #   cmd = "#{cmd} wget -O newspartial_#{idx}.wav #{part.audio.url} ; "
    # end
    # puts! cmd, 'cmd'
    # out = `#{cmd}`
    # puts! out, 'out'

    ## get overlays
    # cmd = "cd #{Rails.root.join('tmp', @newsvideo.id)} ; "
    # @newsvideo.newsoverlays.each_with_index do |overlay, idx|
    #   cmd = "#{cmd} wget -O overlay_#{idx}.mp4 #{overlay.video.video.url} ; "
    # end
    # puts! cmd, 'cmd'
    # out = `#{cmd}`
    # puts! out, 'out'

    ## video concat
#     cmd = <<AOL
#       cd #{Rails.root.join('tmp', @newsvideo.id)} ;
#       rm -f video_concat.mp4 ;
#       ffmpeg -f concat -safe 0 -i videolist.txt -c copy video_concat.mp4 ;
# AOL
#     puts! cmd, 'cmd'
#     out = `#{cmd}`
#     puts! out, 'out'

    ## audio concat
#     audio_filenames = (0...@newsvideo.newspartials.length).map { |i| "newspartial_#{i}.wav" }.join("|")
#     cmd = <<AOL
#       cd #{Rails.root.join('tmp', @newsvideo.id)} ;
#       rm -f audio_concat.wav ;
#       ffmpeg -f concat -safe 0 -i audiolist.txt -c copy audio_concat.wav ;
# AOL
#     puts! cmd, 'cmd'
#     out = `#{cmd}`
#     puts! out, 'out'

    ## combine base
#     cmd = <<AOL
#       cd #{Rails.root.join('tmp', @newsvideo.id)} ;
#       rm -f output.mp4 ;
#       ffmpeg -i video_concat.mp4 -i audio_concat.wav -c:v copy -c:a aac combined_base.mp4 ;
# AOL
#     puts! cmd, 'cmd'
#     out = `#{cmd}`
#     puts! out, 'out'

    ##  combine overlays
    # nn = @newsvideo.newsoverlays.map { |ol| ol.start_at_ms }
    # puts! nn, 'nn'
    # ffmpeg_cmd = [ "ffmpeg -i combined_base.mp4 \\ " ]
    # nn.each_with_index do |ms, idx|
    #   ffmpeg_cmd.push " -i overlay_#{idx}.mp4 \\ "
    # end
    # ffmpeg_cmd.push "-filter_complex \" \\ "
    # #
    # nn.each_with_index do |ms, idx|
    #   ffmpeg_cmd.push " [#{idx+1}:v]setpts=PTS-STARTPTS+#{ms.to_f/1000}/TB[v#{idx+1}]; \\ "
    # end
    # #
    # curr_s = "0:v"
    # n = nil
    # nn.each_with_index do |ms, idx|
    #   n = idx+1
    #   ffmpeg_cmd.push " [#{curr_s}][v#{n}]overlay=0:0:eof_action=pass[tmp#{n}]; \\ "
    #   curr_s = "tmp#{n}"
    # end
    # ffmpeg_cmd.push " \" -map \"[#{curr_s}]\" -map 0:a? -c:v libx264 -c:a copy combined_fin.mp4 "
    # ffmpeg_cmd = ffmpeg_cmd.join("\n")
    # puts "+++ ffmpeg_cmd:"
    # puts ffmpeg_cmd

    # combine overlays 2
#     cmd = <<AOL
#       cd #{Rails.root.join('tmp', @newsvideo.id)} ;
#       rm -f combined_fin.mp4 ;
#       #{ffmpeg_cmd} ;
# AOL
#     puts! cmd, 'cmd'
#     out = `#{cmd}`
#     puts! out, 'out'

    ## upload the video.
    @video = Wco::Video.new name: @newsvideo.title
    video_path = Rails.root.join("tmp", @newsvideo.id, "combined_fin.mp4")
    @video.video = File.open(video_path)
    @video.save!

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
    @newsoverlays = @newsvideo.newsoverlays
    @skip_footer = true
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

    sentences = PragmaticSegmenter::Segmenter.new(text: @newsvideo.body).segment
    phrases = sentences_to_phrases(sentences)
    # puts! phrases, 'phrases'
    phrases.each do |phrase|
      newspartial = Wco::Newspartial.new body: phrase, newsvideo: @newsvideo
      newspartial.save!
    end

    flash_notice 'All done.'
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

  def sentences_to_phrases sentences
    max_words = 50
    phrases = []
    current_phrase = []

    current_word_count = 0

    sentences.each do |sentence|
      words_in_sentence = sentence.split.size

      # If adding this sentence exceeds the limit, start a new phrase
      if current_word_count + words_in_sentence > max_words
        phrases << current_phrase.join(" ")
        current_phrase = []
        current_word_count = 0
      end

      current_phrase << sentence
      current_word_count += words_in_sentence
    end

    # Add the last phrase if any
    phrases << current_phrase.join(" ") unless current_phrase.empty?
  end

  def set_lists
    @tags_list = Wco::Tag.list
  end

end
