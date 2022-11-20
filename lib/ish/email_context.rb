
#
# Sends a single email, or a campaign.
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w| piousbox@gmail.com victor@piousbox.com victor@wasya.co no-reply@piousbox.com |
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  TYPE_SINGLE = 'TYPE_SINGLE'
  TYPE_CAMPAIGN = 'TYPE_CAMPAIGN'
  field :type, default: TYPE_SINGLE
  def self.types_list
    [ [TYPE_SINGLE, TYPE_SINGLE], [TYPE_CAMPAIGN, TYPE_CAMPAIGN] ]
  end


  field :subject
  validates_presence_of :subject

  field :body
  # validates_presence_of :body ## With plain type, there is no body but there are variables for templating.

  belongs_to :email_template

  field :rendered_str

  field :sent_at, type: DateTime
  field :scheduled_at, type: DateTime

  def leads
    if self.type == TYPE_CAMPAIGN
      return ::EmailCampaignLead.where( email_campaign_id: self.id.to_s ).includes( :lead ).map { |p| p.lead }
    end
  end


  #
  # For templating:
  #
  field :tmpl_name

  field :to_email
  validates_presence_of :to_email, if: -> { type == TYPE_SINGLE }

  #
  # For tracking
  #
  attr_reader :tid

end
EmailContext = Ish::EmailContext
