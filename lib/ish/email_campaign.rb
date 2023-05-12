
##
## Sends a campaign.
## _vp_ 2023-02-02
##
class Ish::EmailCampaign
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'ish_email_campaigns'

  field :slug
  validates_uniqueness_of :slug, allow_nil: true

  PAGE_PARAM_NAME = 'email_contexts_page'

  field :from_email
  validates_presence_of :from_email
  FROM_EMAILS = %w|    hello@infiniteshelter.com no-reply@infiniteshelter.com
    piousbox@gmail.com hello@piousbox.com        no-reply@piousbox.com        victor@piousbox.com
    admin@wasya.co     hello@wasya.co            no-reply@wasya.co            victor@wasya.co |
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  belongs_to :email_template
  def tmpl; email_template; end

  field :subject
  field :body

  field :sent_at, type: DateTime
  field :send_at, type: DateTime

  def campaign_leads
    return ::EmailCampaignLead.where( email_campaign_id: self.id.to_s ).includes( :lead )
  end

  def leads
    ::Lead.joins( :email_campaign_leads ).where( 'email_campaign_leads.email_campaign_id' => self.id.to_s )
  end

  ##
  ## For tracking
  ##
  attr_reader :tid

  def do_send
    leads.each do |lead|
      ctx = Ctx.create!({
        email_template: tmpl,
        from_email:     tmpl.from_email,
        lead_id:        lead.id,
        send_at:        Time.now,
        subject:        tmpl.subject,
      })
    end
  end

end
