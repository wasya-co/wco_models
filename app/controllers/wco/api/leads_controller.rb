
class Wco::Api::LeadsController < Wco::ApiController

  skip_before_action :decode_jwt
  before_action      :check_credentials, only: [ :by_email ]

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
