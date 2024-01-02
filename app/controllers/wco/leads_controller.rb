
class Wco::LeadsController < Wco::ApplicationController

  before_action :set_lists

  def index
    authorize! :index, Wco::Lead
    @leads = Wco::Lead.all

    # if params[:q].present?
    #   @leads = @leads.where(" email LIKE ? or name LIKE ? ", "%#{params[:q]}%", "%#{params[:q]}%" )
    # end

    # if params[:q_tag_ids].present?
    #   carry = nil
    #   params[:q_tag_ids].each do |term_id|
    #     lts = LeadTag.where({ term_id: term_id }).map(&:lead_id)
    #     if carry
    #       carry = carry & lts
    #     else
    #       carry = lts
    #     end
    #   end
    #   @leads = Lead.where({ :id.in => carry })
    # end

    @leads = @leads.page( params[:leads_page ] ).per( current_profile.per_page )
  end

  def show
    @lead      = Wco::Lead.where({ id: params[:id] }).first
    @lead    ||= Wco::Lead.where({ email: params[:id] }).first
    if !@lead
      flash_alert "This lead does not exist"
      redirect_to request.referrer
      return
    end
    authorize! :show, @lead
    # @schs      = Sch.where( lead_id: @lead.id )
    # @ctxs      = Ctx.where( lead_id: @lead.id )
    # @convs     = Conv.find( Office::EmailConversationLead.where( lead_id: @lead.id ).map( &:email_conversation_id ) )
    # @msgs      = Msg.where( from: @lead.email )
    # @galleries = @lead.galleries.page( params[:galleries_page] ).per( current_profile.per_page )
    # @videos    = @lead.videos.page( params[:videos_page]       ).per( current_profile.per_page )
  end

  ##
  ## private
  ##
  private

  def set_lists
    @email_campaigns_list = [[nil,nil]] + WcoEmail::Campaign.all.map { |c| [ c.slug, c.id ] }
    @tags_list            = Wco::Tag.list
  end


end

