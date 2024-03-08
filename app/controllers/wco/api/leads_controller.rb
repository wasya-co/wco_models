
class Wco::Api::LeadsController < Wco::ApiController

  def index_hash
    authorize! :index, Wco::Lead
    @leads = Wco::Lead.find( params[:lead_ids].split(',') )
  end

end
