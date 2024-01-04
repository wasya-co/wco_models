
class Wco::HeadlinesController < Wco::ApplicationController

  before_action :set_lists

  def create
    params[:headline][:tag_ids].delete ''

    @headline = Wco::Headline.new( params[:headline].permit! )
    authorize! :create, @headline

    @headline.date = Time.now.to_date

    if @headline.save
      flash_notice @headline
    else
      flash_alert @headline
    end
    redirect_to action: :index
  end

  def destroy
    @headline = Wco::Headline.find params[:id]
    authorize! :delete, @headline
    @headline.delete
    flash_notice "Probably ok"
    redirect_to action: :index
  end

  def new
    authorize! :new, Wco::Headline
  end

  def edit
    @headline = Wco::Headline.find params[:id]
    authorize! :edit, @headline
  end

  def index
    @headlines = Wco::Headline.all
    authorize! :index, Wco::Headline
  end

  def update
    @headline = Wco::Headline.find params[:id]
    authorize! :update, @headline

    params[:headline][:tag_ids].delete ''

    if @headline.update params[:headline].permit!
      flash_notice @headline
    else
      flash_alert @headline
    end
    redirect_to action: :index
  end

  ##
  ## private
  ##
  private

  def set_lists
    @sites_list = Wco::Site.list
    @tags_list = Wco::Tag.list
  end


end

