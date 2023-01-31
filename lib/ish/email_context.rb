
#
# Sends a single email, or a campaign.
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  def slug
    title
  end

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w| piousbox@gmail.com victor@piousbox.com no-reply@piousbox.com
    admin@wasya.co hello@wasya.co no-reply@wasya.co victor@wasya.co |
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
  field :send_at, type: DateTime

  def self.all_campaigns
    Ish::EmailContext.where( type: TYPE_CAMPAIGN )
  end

  def self.unsent_campaigns
    Ish::EmailContext.where( type: TYPE_CAMPAIGN, sent_at: nil )
  end

  def campaign_leads
    if self.type == TYPE_CAMPAIGN
      return ::EmailCampaignLead.where( email_campaign_id: self.id.to_s ).includes( :lead )
    end
  end

  def leads
    campaign_leads&.map { |p| p.lead }
  end

  def self.unsent
    new.unsent
  end
  def unsent
    where( sent_at: nil )
  end

  def self.current
    new.current
  end
  def current
    # or({ :send_at.lte => Time.now }, { :send_at => nil }) ## This won't work b/c I need draft state!
    where({ :send_at.lte => Time.now  })
  end


  ##
  ## For templating:
  ##
  ## commonly: name, companyName
  field :tmpl, type: Hash, default: {}
  def body_templated
    out = email_template.body
    tmpl.each do |k, v|
      out.gsub!("{#{k}}", v)
    end
    out
  end

  field :to_email
  validates_presence_of :to_email, if: -> { type == TYPE_SINGLE }

  #
  # For tracking
  #
  attr_reader :tid

end
EmailCampaign = Ish::EmailContext
