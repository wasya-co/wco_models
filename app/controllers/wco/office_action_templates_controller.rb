
OAT = Wco::OfficeActionTemplate

class Wco::OfficeActionTemplatesController < Wco::ApplicationController

  before_action :set_lists

  def index
    authorize! :index, OAT
  end

  def new
    @oat = OAT.new
    authorize! :new, @oat


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
  end


end
