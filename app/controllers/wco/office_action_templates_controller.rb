
OAT = Wco::OfficeActionTemplate

class Wco::OfficeActionTemplatesController < Wco::ApplicationController

  def index
    authorize! :index, OAT
  end

end
