
class Wco::SitesController < Wco::ApplicationController

  def create
    @site = Wco::Site.new params[:site].permit!
    authorize! :create, @site
    if @site.save
      flash_notice "created site"
    else
      flash_alert "Cannot create site: #{@site.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def destroy
    @site = Wco::Site.find params[:id]
    authorize! :destroy, @site
    if @site.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to action: 'index'
  end

  def edit
    @site = Wco::Site.find params[:id]
    authorize! :edit, @site
  end

  def index
    authorize! :index, Wco::Site
    @sites = Wco::Site.all
  end

  def new
    authorize! :new, Wco::Site
    @new_site = Wco::Site.new
  end

  def update
    @site = Wco::Site.find params[:id]
    authorize! :update, @site
    if @site.update params[:site].permit!
      flash_notice "updated site"
    else
      flash_alert "Cannot update site: #{@site.errors.messages}"
    end
    redirect_to action: 'index'
  end

end
