
class Wco::TagsController < Wco::ApplicationController

  before_action :set_lists, only: %i| show |

  def create
    @tag = Wco::Tag.new params[:tag].permit!
    authorize! :create, @tag
    if @tag.save
      flash_notice "created tag"
    else
      flash_alert "Cannot create tag: #{@tag.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def destroy
    @tag = Wco::Tag.find params[:id]
    authorize! :destroy, @tag
    if @tag.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to action: 'index'
  end

  def edit
    @tag = Wco::Tag.find params[:id]
    authorize! :edit, @tag
  end

  def index
    authorize! :index, Wco::Tag
    @tags = Wco::Tag.all
  end

  def new
    authorize! :new, Wco::Tag
    @new_tag = Wco::Tag.new
  end

  def add_to
    @tag = Wco::Tag.find params[:id]
    resource = params[:resource].constantize.find params[:resource_id]
    authorize! :update, @tag

    resource.tags.push @tag
    flag = resource.save
    flash_notice 'maybe?'
    redirect_to request.referrer
  end

  def remove_from
    @tag = Wco::Tag.find params[:id]
    resource = params[:resource].constantize.find params[:resource_id]
    authorize! :update, @tag

    resource.tags.delete @tag
    flag = resource.save
    flash_notice 'maybe?'
    redirect_to request.referrer
  end

  def show
    @tag = Wco::Tag.find params[:id]
    authorize! :show, @tag

    @galleries = @tag.galleries(
      ).page( params[:galleries_page] ).per( current_profile.per_page )

    @reports = @tag.reports(
      ).page( params[:reports_page] ).per( current_profile.per_page )

  end

  def update
    @tag = Wco::Tag.find params[:id]
    authorize! :update, @tag
    if @tag.update params[:tag].permit!
      flash_notice "updated tag"
    else
      flash_alert "Cannot update tag: #{@tag.errors.messages}"
    end
    redirect_to action: 'index'
  end

  ##
  ## private
  ##
  private

  def set_lists
    @tags = Wco::Tag.all
  end


end
