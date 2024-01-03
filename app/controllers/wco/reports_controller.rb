
class Wco::ReportsController < Wco::ApplicationController

  def create
    @report = Wco::Report.new params[:report].permit!
    authorize! :create, @report
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
    @report = Wco::Report.find params[:id]
    authorize! :edit, @report
  end

  def index
    authorize! :index, Wco::Report
    @reports = Wco::Report.all
  end

  def new
    authorize! :new, Wco::Report
    @new_report = Wco::Report.new
  end

  def update
    @report = Wco::Report.find params[:id]
    authorize! :update, @report
    if @report.update params[:report].permit!
      flash_notice "updated report"
    else
      flash_alert "Cannot update report: #{@report.errors.messages}"
    end
    redirect_to action: 'index'
  end

end
