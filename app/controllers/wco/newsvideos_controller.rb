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

    Rails.env.production? ?
      Wco::NewsvideoGenerateJob.perform_async(@newsvideo.id.to_s) :
      Wco::NewsvideoGenerateJob.perform_sync( @newsvideo.id.to_s)

    render json: { status: :ok, message: 'Scheduled the generation' }
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
    puts! phrases, 'phrases'

    phrases.each do |phrase|
      newspartial = Wco::Newspartial.new body: phrase, newsvideo: @newsvideo
      newspartial.save!
    end

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
