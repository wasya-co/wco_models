
OAT = Wco::OfficeActionTemplate
OA  = Wco::OfficeAction

class Wco::OfficeActionsController < Wco::ApplicationController

  before_action :set_lists

  def create
    @oa = OA.new params[:oa].permit!
    authorize! :update, @oa

    if @oa.save
      flash_notice @oa
    else
      flash_alert @oa
    end
    redirect_to action: :index
  end

  def edit
    @oa = OA.find params[:id]
    authorize! :edit, @oa
  end

  def index
    authorize! :index, OA
    @oas = OA.all
  end

  def new
    @oa = OA.new
    authorize! :new, @oa
  end

  def show
    @oa = OA.find params[:id]
    authorize! :show, @oa
  end

  def update
    @oa = OA.find params[:id]
    authorize! :update, @oa

    if @oa.update params[:oa].permit!
      flash_notice @oa
    else
      flash_alert @oa
    end
    redirect_to action: :index
  end

  ##
  ## private
  ##
  private

  def set_lists
    @from_types_list = [ nil, 'Wco::Gallery', 'Wco::Tag' ]
    @from_type = params[:from_type]
    @from_ids_list = []
    if @from_type.present?
      @from_ids_list = @from_type.constantize.list
    end
    @publishers_list = Wco::Publisher.list

    @oats_list = OAT.list
  end


end
