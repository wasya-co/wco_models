
#
# Sends a single email
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  ## @TODO: probably rename it to slug
  field :slug
  validates_uniqueness_of :slug, allow_nil: true
  def title
    slug
  end

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w| hello@infiniteshelter.com no-reply@infiniteshelter.com
    piousbox@gmail.com victor@piousbox.com no-reply@piousbox.com
    admin@wasya.co hello@wasya.co no-reply@wasya.co victor@wasya.co |
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  field :subject
  validates_presence_of :subject

  field :body
  # validates_presence_of :body ## With plain type, there is no body but there are variables for templating.

  belongs_to :email_template

  field :rendered_str

  field :sent_at, type: DateTime
  field :send_at, type: DateTime


  def self.unsent
    new.unsent
  end
  def unsent
    Ish::EmailContext.where( sent_at: nil )
  end

  def self.current
    new.current
  end
  def current
    # or({ :send_at.lte => Time.now }, { :send_at => nil }) ## This won't work b/c I need draft state!
    Ish::EmailContext.where({ :send_at.lte => Time.now  })
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
  validates_presence_of :to_email

  #
  # For tracking
  #
  attr_reader :tid

end
