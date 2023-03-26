##
## Send a single email
##

class ::Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  validates_uniqueness_of :slug, allow_nil: true

  field :preview_str, type: :string
  def preview_str
    if self[:preview_str].presence
      return self[:preview_str]
    else
      return tmpl.preview_str
    end
  end

  field :body
  def body
    if self[:body].presence
      return self[:body]
    else
      return tmpl.body
    end
  end

  PAGE_PARAM_NAME = 'email_contexts_page'

  field :from_email
  # validates_presence_of :from_email

  field :subject
  # validates_presence_of :subject



  belongs_to :email_template
  def tmpl; email_template; end

  belongs_to :scheduled_email_action, class_name: '::Office::ScheduledEmailAction', optional: true
  def sch; scheduled_email_action; end

  field :rendered_str

  field :sent_at, type: DateTime
  field :send_at, type: DateTime


  def self.unsent; new.unsent; end
  def unsent; Ish::EmailContext.where( sent_at: nil ); end

  def self.scheduled; new.scheduled; end
  def scheduled
    # or({ :send_at.lte => Time.now }, { :send_at => nil }) ## This won't work b/c I need draft state!
    Ish::EmailContext.where({ :send_at.lte => Time.now  })
  end

  def self.from_email_list
    Ish::EmailCampaign.from_email_list
  end

  field :lead_id, type: :integer
  def lead; Lead.find( lead_id ); end
  def to_email; lead[:email]; end


  ##
  ## For tracking / utm
  ##
  attr_reader :tid

  def get_binding
    @lead = lead()
    binding()
  end

end
Ctx = ::Ish::EmailContext

