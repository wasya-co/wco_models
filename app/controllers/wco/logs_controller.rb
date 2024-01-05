
class Wco::LogsController < Wco::ApplicationController

  def bulkop
    @logs = Wco::Log.find params[:ids]
    authorize! :delete, @logs
    case params[:verb]
    when 'delete'
      @logs.map &:delete
    end
    flash_notice "Probably ok"
    redirect_to request.referrer
  end

  def create
    @log = Wco::Log.new( params[:log].permit! )
    authorize! :create, @log

    if @log.save
      flash_notice @log
    else
      flash_alert @log
    end
    redirect_to action: :index
  end

  def destroy
    @log = Wco::Log.find params[:id]
    authorize! :delete, @log
    @log.delete
    flash_notice "Probably ok"
    redirect_to action: :index
  end

  def new
    authorize! :new, Wco::Log
  end

  def edit
    @log = Wco::Log.find params[:id]
    authorize! :edit, @log
  end

  def index
    @logs = Wco::Log.all
    authorize! :index, Wco::Log
    render '_index'
  end

  def update
    @log = Wco::Log.find params[:id]
    authorize! :update, @log

    if @log.update params[:log].permit!
      flash_notice @log
    else
      flash_alert @log
    end
    redirect_to action: :index
  end


end

