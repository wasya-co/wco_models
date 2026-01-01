
class Wco::NewspartialsController < Wco::ApplicationController

  before_action :set_lists

  def create
    params[:newspartial][:tag_ids]&.delete ''

    @newspartial = Wco::Newspartial.new params[:newspartial].permit!
    authorize! :create, @newspartial

    if @newspartial.save
      flash_notice "created newspartial"
    else
      flash_alert "Cannot create newspartial: #{@newspartial.errors.messages}"
    end
    redirect_to controller: 'newsvideos', id: @newspartial.newsvideo_id, action: 'show'
  end

  def destroy
    @newspartial = Wco::Newspartial.find params[:id]
    authorize! :destroy, @newspartial
    if @newspartial.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to action: 'index'
  end

  def edit
    @newspartial = Wco::Newspartial.unscoped.find params[:id]
    authorize! :edit, @newspartial
  end

  def generate_speech
    @newspartial = Wco::Newspartial.unscoped.find params[:id]
    authorize! :show, @newspartial
    @newspartial.generate_speech
    redirect_to controller: 'newsvideos', id: @newspartial.newsvideo_id, action: 'show'
  end

  def generate_video
    @newspartial = Wco::Newspartial.unscoped.find params[:id]
    authorize! :show, @newspartial
    @newspartial.generate_video
    redirect_to controller: 'newsvideos', id: @newspartial.newsvideo_id, action: 'show'
  end

  def index
    authorize! :index, Wco::Newspartial
    @newspartials = Wco::Newspartial.all
    if params[:deleted]
      @newspartials = Wco::Newspartial.unscoped.where( :deleted_at.ne => nil )
    end
    @newspartials = @newspartials.page( params[:newspartials_page] ).per( current_profile.per_page )
  end

  def new
    authorize! :new, Wco::Newspartial
    @newspartial = Wco::Newspartial.new
  end

  def show
    @newspartial = Wco::Newspartial.unscoped.find params[:id]
    authorize! :show, @newspartial

    # @config = JSON.parse( @newspartial.config_json )
    # @duration_ms = @config['vtimes'].last.to_i + @config['vdurations'].last.to_i
  end

  def update
    params[:newspartial][:tag_ids]&.delete ''

    @newspartial = Wco::Newspartial.unscoped.find params[:id]
    authorize! :update, @newspartial
    if @newspartial.update params[:newspartial].permit!
      flash_notice "updated newspartial"
    else
      flash_alert "Cannot update newspartial: #{@newspartial.errors.messages}"
    end
    redirect_to action: 'index'
  end

  ##
  ## private
  ##
  private

  def set_lists
    @tags_list = Wco::Tag.list
    @newsvideos_list = Wco::Newsvideo.list
  end

end
