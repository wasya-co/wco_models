
##
## Such actions as auto-responder.
##
class Office::Action
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status,     type: String, default: 'active'
  field :channel,    type: String ## eg 'email'
  field :match_from, type: String ## eg '@synchrony.com', '*@synchrony.com$'

  scope :active, -> { where( status: 'active' ) }

  ## eg [ { 'method': 'create_lead', 'params': {} },
  ##      { 'method': 'autorespond',  'params': {}, ... ]
  field :actions, type: Array, default: []

  def self.create_lead params
    msg = params[:msg]
    leadset = Leadset.find_or_create_by({ company_url: msg.company_url })
    lead = Lead.new({
      email: msg.from_str,
      name: msg.name,
      leadset: leadset,
    })
    lead.save
  end

  def self.autorespond params
    msg = params[:msg]
    email_template = ::Ish::EmailTemplate.find_by!({ slug: '20230207-autorespond' })
    email_ctx = ::Ish::EmailContext.new({
      to_email: '',
      subject: '',
      from_email: '',
      body: '',
      email_template_id: email_template.id.to_s,
    })
    email_ctx.save!
    IshManager::OfficeMailer.send_context_email( email_ctx ).deliver_later
  end

end
