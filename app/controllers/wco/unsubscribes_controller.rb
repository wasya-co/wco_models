
## In order to have unsubscribes_url , unsubscribes must be in wco .
class Wco::UnsubscribesController < Wco::ApplicationController

  skip_before_action :current_profile, only: [ :create, :do_unsubscribe, :new, ]


  def create
    authorize! :open_permission, Wco
    @lead = Wco::Lead.find params[:lead_id]

    if( !params[:token] ||
        @lead.unsubscribe_token != params[:token] )
      render code: 400, message: "We're sorry, but something went wrong. Please try again later."
      return
    end

    @unsubscribe = WcoEmail::Unsubscribe.find_or_create_by({
      lead_id:     params[:lead_id],
      template_id: params[:template_id],
      campaign_id: params[:campaign_id],
    })
    flag = @unsubscribe.update_attributes({
      unsubscribed_at: Time.now,
    })
    if flag
      flash_notice "You have been unsubscribed."
    else
      flash_alert "We're sorry, but something went wrong. Please try again later."
    end

    render layout: false
  end

  def do_unsubscribe
    authorize! :open_permission, Wco
    lead = Wco::Lead.find_by email: params[:email]
    if params[:token] == lead.unsubscribe_token
      lead.update({ unsubscribed_at: Time.now })
      flash[:notice] = 'You have been unsubscribed!'
      render 'success', layout: false
    else
      flash[:error] = 'security token mismatch.'
      render 'error', layout: false
    end
  end

  def index
    authorize! :index, WcoEmail::Unsubscribe
    @unsubscribes = WcoEmail::Unsubscribe.all

    render '_table'
  end

  def new
    authorize! :open_permission, Wco
    render layout: false
  end

  ##
  ## private
  ##
  private

  def set_lists
    ; ## no super
  end

end

