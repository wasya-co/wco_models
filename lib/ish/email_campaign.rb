
#
# Sends a campaign.
# _vp_ 2023-02-02
#

class Ish::EmailCampaign
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  def slug
    title
  end

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w| hello@infiniteshelter.com no-reply@infiniteshelter.com
    piousbox@gmail.com hello@piousbox.com no-reply@piousbox.com victor@piousbox.com
    admin@wasya.co hello@wasya.co no-reply@wasya.co victor@wasya.co |
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  field :subject
  validates_presence_of :subject

  field :body
  # validates_presence_of :body

  belongs_to :email_template

  field :sent_at, type: DateTime
  field :send_at, type: DateTime

  def campaign_leads
    return ::EmailCampaignLead.where( email_campaign_id: self.id.to_s ).includes( :lead )
  end

  def leads
    campaign_leads&.map { |p| p.lead }
  end


  # ##
  # ## For templating:
  # ##
  # ## commonly: name, companyName
  # field :tmpl, type: Hash, default: {}
  # def body_templated
  #   out = email_template.body
  #   tmpl.each do |k, v|
  #     out.gsub!("{#{k}}", v)
  #   end
  #   out
  # end

  #
  # For tracking
  #
  attr_reader :tid

end
