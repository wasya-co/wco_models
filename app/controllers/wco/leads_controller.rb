
class Wco::LeadsController < Wco::ApplicationController
  before_action :set_lists

  def create
    params[:lead][:tag_ids]&.delete ''
    params[:lead].delete :leadset_id if params[:lead][:leadset_id].blank?

    @lead = Wco::Lead.new params[:lead].permit!
    authorize! :create, @lead

    if params[:lead][:photo]
      photo = Wco::Photo.new photo: params[:lead][:photo]
      photo.is_public = true
      if photo.save
        @lead.photo = photo
      end
      params[:lead].delete :photo
    end

    if @lead.save
      flash_notice 'ok'
    else
      flash_alert @lead
    end
    redirect_to action: :index
  end

  def create_import
    authorize! :create, Wco::Lead
    file = params[:file]
    selected_tag_ids = params[:tags] || []

    if file.nil?
      redirect_back fallback_location: root_path, alert: "No file selected" and return
    end

    CSV.foreach(file.path, headers: true) do |row|
      lead_attrs = {
        email:   row['email'] || row['Email'],
        name:    row['name'] || row['Name'],
        phone:   row['phone'] || row['Phone'],
        address: row['address'] || row['Address']
      }.compact ## skip missing columns

      lead   = Wco::Lead.find_by( email: lead_attrs[:email] ) rescue nil
      lead ||= Wco::Lead.create!(lead_attrs)

      # Assign selected tags
      selected_tag_ids.each do |tag_id|
        lead.tags << Wco::Tag.find(tag_id)
      end
      # lead.save!
    end

    redirect_to wco.leads_path, notice: "Leads imported successfully"
  rescue => e
    redirect_back fallback_location: root_path, alert: "Error: #{e.message}"
  end

  def edit
    authorize! :edit, Wco::Lead
    @lead = Wco::Lead.find params[:id]
  end

  def index
    authorize! :index, Wco::Lead
    @leads = Wco::Lead.all

    if params[:q].present?
      q = params[:q].downcase
      @leads = @leads.any_of(
        { email: /#{q}/i },
        { name:  /#{q}/i },
      );

      if 1 == @leads.length
        redirect_to controller: 'wco/leads', action: 'show', id: @leads[0].id
        return
      end
    end

    @leads = @leads.includes( :tags )
    @leads = @leads.page( params[:leads_page ] ).per( current_profile.per_page )
  end

  def new
    authorize! :new, Wco::Lead
    @lead = Wco::Lead.new
  end

  def new_import
    authorize! :new, Wco::Lead
  end

  def show
    @lead      = Wco::Lead.where({ id: params[:id] }).first
    @lead    ||= Wco::Lead.where({ email: params[:id] }).first
    authorize! :show, @lead
    if !@lead
      flash_alert "This lead does not exist"
      redirect_to request.referrer
      return
    end
    @ctxs  = @lead.ctxs.page(          params[:ctxs_page]  ).per( current_profile.per_page )
    @convs = @lead.conversations.page( params[:convs_page] ).per( current_profile.per_page )

  end

  def update
    params[:lead][:tag_ids]&.delete ''
    params[:lead].delete :leadset_id if params[:lead][:leadset_id].blank?

    @lead = Wco::Lead.find params[:id]
    authorize! :update, @lead

    if params[:lead][:photo]
      photo = Wco::Photo.new photo: params[:lead][:photo]
      photo.is_public = true
      if photo.save
        @lead.photo = photo
      end
      params[:lead].delete :photo
    end

    if @lead.update params[:lead].permit!
      flash_notice 'ok'
    else
      puts! @lead.errors.full_messages.join(", "), 'cannot update lead'
      flash_alert @lead
    end
    redirect_to action: :show, id: @lead.id
  end

  ##
  ## private
  ##
  private

  def set_lists
    @email_campaigns_list = [[nil,nil]] + WcoEmail::Campaign.all.map { |c| [ c.slug, c.id ] }
    @email_templates_list = WcoEmail::EmailTemplate.list
    @leads_list           = Wco::Lead.list
    @leadsets_list        = Wco::Leadset.list
    @tags_list            = Wco::Tag.list
  end


end

