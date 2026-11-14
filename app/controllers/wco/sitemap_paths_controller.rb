
class Wco::SitemapPathsController < Wco::ApplicationController

  before_action :fix_params, only: [ :create, :update ]

  def check
    @spath = Wco::SitemapPath.find params[:id]
    authorize! :check, @spath
    @spath.check
    redirect_to wco.spath_path(@spath)
  end

  def clear
    @spath = Wco::SitemapPath.find params[:id]
    authorize! :clear, @spath
    @spath.logs.destroy_all
    redirect_to request.referrer || sites_path(@spath.site)
  end

  def create
    authorize! :create, Wco::SitemapPath
    @spath = Wco::SitemapPath.new params[:spath].permit!

    if @spath.save
      flash_notice 'Success.'
      redirect_to wco.site_path(params[:spath][:site_id])
    else
      flash_alert "Could not save spath: #{@spath.errors.full_messages}"
      render 'new'
    end
  end

  def destroy
    @spath = Wco::SitemapPath.find params[:id]
    site_id = @spath.site_id
    authorize! :destroy, @spath
    if @spath.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to request.referrer || sites_path(site_id)
  end

  def edit
    @spath = Wco::SitemapPath.find params[:id]
    @site = @spath.site
    authorize! :edit, @spath
  end

  def new
    @site = Wco::Site.find( params[:site_id] )
    @spath = Wco::SitemapPath.new site: @site
    authorize! :new, @spath
  end

  def show
    @spath = Wco::SitemapPath.find params[:id]
    @site = @spath.site
    authorize! :show, @spath
  end


  def update
    @spath = Wco::SitemapPath.find params[:id]
    authorize! :update, @spath
    flag = @spath.update params[:spath].permit!
    if flag
      flash_notice 'Success'
      redirect_to site_path(@spath.site)
    else
      flash_alert 'No luck.'
      render action: 'edit'
    end

  end

  ##
  ## private
  ##
  private

  def fix_params
    if params[:spath][:selectors].present?
      params[:spath][:selectors] =  params[:spath][:selectors].split(',').strip
    else
      params[:spath][:selectors] = []
    end
  end


end

