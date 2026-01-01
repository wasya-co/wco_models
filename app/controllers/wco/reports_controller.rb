
class Wco::ReportsController < Wco::ApplicationController

  before_action :set_lists

  def create
    params[:report][:tag_ids]&.delete ''

    @report = Wco::Report.new params[:report].permit!
    authorize! :create, @report
    @report.author = current_profile
    if @report.save
      flash_notice "created report"
    else
      flash_alert "Cannot create report: #{@report.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def destroy
    @report = Wco::Report.find params[:id]
    authorize! :destroy, @report
    if @report.destroy
      flash_notice 'ok'
    else
      flash_alert 'No luck.'
    end
    redirect_to action: 'index'
  end

  def edit
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :edit, @report
  end

  def index
    authorize! :index, Wco::Report
    @reports = Wco::Report.all
    if params[:deleted]
      @reports = Wco::Report.unscoped.where( :deleted_at.ne => nil )
    end
    @reports = @reports.page( params[:reports_page] ).per( current_profile.per_page )
  end

  def new
    authorize! :new, Wco::Report
    @new_report = Wco::Report.new
  end

  def show
    @report = Wco::Report.unscoped.find params[:id]
    authorize! :show, @report

    # @config = JSON.parse( @report.config_json )
    # @duration_ms = @config['vtimes'].last.to_i + @config['vdurations'].last.to_i
  end

  def update
    params[:report][:tag_ids]&.delete ''

    @report = Wco::Report.unscoped.find params[:id]
    authorize! :update, @report
    if @report.update params[:report].permit!
      flash_notice "updated report"
    else
      flash_alert "Cannot update report: #{@report.errors.messages}"
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
