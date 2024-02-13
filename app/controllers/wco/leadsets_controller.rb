
Leadset = Wco::Leadset

class Wco::LeadsetsController < Wco::ApplicationController

  before_action :set_lists

  ## alphabetized : )

  def create
    params[:leadset][:serverhost_ids].delete ''
    @leadset = Leadset.new params[:leadset].permit!
    authorize! :create, @leadset
    if @leadset.save
      flash[:notice] = "created leadset"
    else
      flash[:alert] = "Cannot create leadset: #{@leadset.errors.messages}"
    end
    redirect_to :action => 'index'
  end

  def destroy
    leadsets = Leadset.find( params[:leadset_ids] )
    @results = []
    leadsets.each do |leadset|
      @results.push leadset.discard
    end
    flash[:notice] = "Discard outcome: #{@results.inspect}."
    redirect_to action: 'index'
  end

  def edit
    @leadset = Leadset.find params[:id]
    authorize! :edit, @leadset
  end

  def index
    authorize! :index, Leadset
    @leadsets = Leadset.all.includes(:leads)
    if params[:q].present?
      @leadsets = @leadsets.where({ company_url: /.*#{params[:q]}.*/i })
      if @leadsets.length == 1
        return redirect_to action: :show, id: @leadsets[0][:id]
      end
    end
    @leadsets = @leadsets.page( params[:leadsets_page] ).per( current_profile.per_page )
  end

  def new
    @new_leadset = Leadset.new
    authorize! :new, @new_leadset
  end

  def show
    @leadset = Leadset.find params[:id]
    authorize! :show, @leadset

    @email_contexts = {}
    @leadset.leads.each do |lead|
      @email_contexts[lead.email] = lead.email_contexts
    end

    @leads     = @leadset.leads.page( params[:leads_page] ).per( current_profile.per_page )
    @subscriptions = @leadset.subscriptions
    @invoices      = @leadset.invoices
  end

  def update
    params[:leadset][:serverhost_ids].delete ''
    @leadset = Leadset.find params[:id]
    authorize! :update, @leadset
    if @leadset.update_attributes params[:leadset].permit!
      flash[:notice] = 'Successfully updated leadset.'
    else
      flash[:alert] = "Cannot update leadset: #{@leadset.errors.messages}"
    end
    redirect_to :action => 'show', id: @leadset.id
  end

  ##
  ## private
  ##
  private

  def set_lists
    @serverhosts_list     = WcoHosting::Serverhost.list
    @tags_list            = Wco::Tag.list
    @leads_list           = Wco::Lead.all.map { |lead| [ lead.email, lead.id ] }
    @templates_list       = WcoEmail::EmailTemplate.all.map { |t| [ t.slug, t.id ] }
    @email_campaigns_list = WcoEmail::Campaign.list
  end

end
