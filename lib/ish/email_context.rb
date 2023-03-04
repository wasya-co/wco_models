
#
# Sends a single email
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  ## @TODO: probably rename it to slug
  field :slug
  validates_uniqueness_of :slug, allow_nil: true

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w|
    hello@infiniteshelter.com no-reply@infiniteshelter.com
    piousbox@gmail.com
    victor@piousbox.com no-reply@piousbox.com
    admin@wasya.co hello@wasya.co no-reply@wasya.co victor@wasya.co
  |;
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  field :subject
  validates_presence_of :subject

  field :body

  belongs_to :email_template
  belongs_to :scheduled_email_action, class_name: '::Office::ScheduledEmailAction', optional: true

  field :rendered_str

  field :sent_at, type: DateTime
  field :send_at, type: DateTime


  def self.unsent
    new.unsent
  end
  def unsent
    Ish::EmailContext.where( sent_at: nil )
  end

  def self.scheduled
    new.scheduled
  end
  def scheduled
    # or({ :send_at.lte => Time.now }, { :send_at => nil }) ## This won't work b/c I need draft state!
    Ish::EmailContext.where({ :send_at.lte => Time.now  })
  end

  ## @deprecated: use self.lead
  # field :to_email
  # validates_presence_of :to_email

  field :lead_id
  def lead
    Lead.find lead_id
  end

  ##
  ## For tracking / utm
  ##
  attr_reader :tid

  def get_binding
    @lead = lead()
    binding()
  end

end
