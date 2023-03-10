
#
# Sends a single email
#

class ::Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  ## @TODO: probably rename it to slug
  field :slug
  validates_uniqueness_of :slug, allow_nil: true

  field :preview_str, type: :string
  def preview_str
    if self[:preview_str].presence?
      return self[:preview_str]
    else
      return tmpl.preview_str
    end
  end

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = [
    'Infinite Shelter <hello@infiniteshelter.com>',
    'Infinite Shelter <no-reply@infiniteshelter.com>',
    'Victor Piousbox <piousbox@gmail.com>',
    'Victor Piousbox <victor@piousbox.com>',
    'Victor Piousbox <no-reply@piousbox.com>',
    'Victor Piousbox <admin@wasya.co>',
    'WasyaCo Consulting <hello@wasya.co>',
    'WasyaCo Consulting <no-reply@wasya.co>',
    'Victor Piousbox <victor@wasya.co>',
  ];
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  field :subject
  validates_presence_of :subject

  field :body

  belongs_to :email_template
  def tmpl
    email_template
  end

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


  field :lead_id
  def lead
    Lead.find lead_id
  end
  ## @deprecated: use self.lead
  field :to_email
  def to_email
    if self[:lead_id]
      return lead[:email]
    else
      return self[:to_email]
    end
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
