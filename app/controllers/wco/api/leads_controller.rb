
class Wco::Api::LeadsController < Wco::ApiController

  before_action :decode_secret, only: [ :by_email ]
  before_action :decode_jwt,    only: [ :index, :index_hash ]

  def by_email
    @lead = Wco::Lead.find_or_create_by_email( params[:email] )
    render formats: [:json]
  end

  ## select2-leads-ajax
  def index
    authorize! :index, Wco::Lead
    @leads = Wco::Lead.all

    if params[:q].present?
      q = params[:q].downcase
      @leads = @leads.any_of(
        { email: /#{q}/i },
        { name:  /#{q}/i },
      );
    end
  end

  def index_hash
    authorize! :index, Wco::Lead
    @leads = Wco::Lead.find( params[:lead_ids].split(',') )
  end

end
