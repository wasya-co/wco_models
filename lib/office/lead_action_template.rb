
##
##
class Office::LeadActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :lead_actions, class_name: '::Office::LeadAction', inverse_of: :lead_action_templates

  field     :slug
  validates :slug, presence: true

  field     :action_exe, type: :string
  # validates :action_exe, presence: true

  field     :config_json, type: Object, default: '{}'

  field     :kind, type: :string
  KIND_UNSUBSCRIBE_TEMPLATE = 'kind-unsubscribe-template'
  KIND_UNSUBSCRIBE_CAMPAIGN = 'kind-unsubscribe-campaign'
  KINDS                     = [ KIND_UNSUBSCRIBE_TEMPLATE, KIND_UNSUBSCRIBE_CAMPAIGN ]


  def unsubscribe_from_campaign
  end

  def unsubscribe_from_template
    template = EmailTemplate.find( ctx[:template_id] )
    subject  = "Lead #{lead.full_name} unsubscribed from template #{template.slug}"
    out      = Mailer.notify( 'poxlovi@gmail.com', subject )
    Rails.env.production? ? out.deliver_later : out.deliver_now
    Office::Unsubscribe.create({
      lead_id: lead_id,
      template_id: config_json['template_id'],
    })
  end


end

