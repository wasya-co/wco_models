
class Wco::TagsController < Wco::ApplicationController

  before_action :set_lists

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
    redirect_to request.referrer
  end

  def edit
    @tag = Wco::Tag.find params[:id]
    authorize! :edit, @tag
  end

  def index
    authorize! :index, Wco::Tag
    @tags = Wco::Tag.all.order_by( slug: :asc )

    tags = Wco::Tag.all.to_a.group_by(&:parent_id)
    build_tree = lambda do |parent_id|
      (tags[parent_id] || []).sort_by { |tag| tag.slug.downcase }.map do |tag|
        { tag: tag, sons: build_tree.call(tag.id) }
      end
    end
    @tree = build_tree.call(nil)


    @template = params[:template] || 'index_tree'
  end

  def new
    authorize! :new, Wco::Tag
  end

  def new_for_sidebar
    authorize! :new, Wco::Tag
  end
  def create_for_sidebar
    authorize! :create, Wco::Tag
    @current_profile.sidebar_tags.push Wco::Tag.find(params[:tag_id])
    @current_profile.save

    flash_notice 'Ok'
    redirect_to request.referrer
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

  def add_to_many
    @tag = Wco::Tag.find params[:id]
    resources = params[:resource].constantize.find params[:resource_ids]
    authorize! :update, @tag

    flags = []
    resources.each do |resource|
      resource.tags.push @tag
      flags.push resource.save
    end
    flash_notice flags
    # redirect_to request.referrer
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

  def remove_from_many
    @tag = Wco::Tag.find params[:id]
    resources = params[:resource].constantize.find params[:resource_ids]
    authorize! :update, @tag

    flags = []
    resources.each do |resource|
      resource.tags.delete @tag
      flags.push resource.save
    end
    flash_notice flags
    # redirect_to request.referrer
  end

  def show
    @tag = Wco::Tag.find params[:id]
    authorize! :show, @tag

    @galleries = @tag.galleries.page( params[:galleries_page] ).per( current_profile.per_page )
    @leads     = @tag.leads.page( params[::Wco::Lead::PAGE_PARAM_NAME] ).per( current_profile.per_page )
    @leadsets  = @tag.leadsets.page( params[::Wco::Leadset::PAGE_PARAM_NAME] ).per( current_profile.per_page )
    @reports   = @tag.reports.page( params[:reports_page] ).per( current_profile.per_page )

    # render params['template'] || 'show'
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
    super

    @sites_list = Wco::Site.list
  end


end
