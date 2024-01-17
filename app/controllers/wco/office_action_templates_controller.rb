
class Wco::OfficeActionTemplatesController < Wco::ApplicationController

  before_action :set_lists

  def edit
    @oat = OAT.find params[:id]
    @oat.ties.push Wco::OfficeActionTemplateTie.new
    authorize! :edit, @oat
  end

  def index
    authorize! :index, OAT
    @oats = OAT.all
    @new_oat = OAT.new
    @new_oat.ties.push Wco::OfficeActionTemplateTie.new
  end

  def new
    @oat = OAT.new
    @oat.ties.push Wco::OfficeActionTemplateTie.new
    authorize! :new, @oat
  end

  def show
    @oat = OAT.find params[:id]
    authorize! :show, @oat
  end

  def update
    params[:oat][:ties_attributes].permit!
    if params[:id]
      @oat = OAT.find params[:id]
    else
      @oat = OAT.new
    end
    authorize! :upsert, @oat

    if params[:oat][:ties_attributes]
      params[:oat][:ties_attributes].each do |k, v|
        if !v[:next_office_action_template_id].present?
          params[:oat][:ties_attributes].delete( k )
        end
        if v[:to_delete] == "1"
          OATT.find( v[:id] ).delete
          params[:oat][:ties_attributes].delete( k )
        end
      end
    end

    if @oat.update params[:oat].permit!
      flash_notice @oat
    else
      flash_alert @oat
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
