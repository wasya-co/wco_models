
class Wco::LeadsController < Wco::ApplicationController

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

end

