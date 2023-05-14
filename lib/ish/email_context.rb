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
  def subject
    self[:subject].presence || tmpl.subject
  end

  belongs_to :email_template
  def tmpl; email_template; end

  belongs_to :scheduled_email_action, class_name: '::Office::ScheduledEmailAction', optional: true
  def sch; scheduled_email_action; end

  belongs_to :email_campaign, class_name: 'Ish::EmailCampaign', optional: true

  field :rendered_str

  field :sent_at, type: DateTime
  field :send_at, type: DateTime


  def notsent
    Ish::EmailContext.where( sent_at: nil )
  end
  def self.notsent; new.notsent; end


  def scheduled
    # or({ :send_at.lte => Time.now }, { :send_at => nil }) ## This won't work b/c I need draft state!
    Ish::EmailContext.where({ :send_at.lte => Time.now  })
  end
  def self.scheduled; new.scheduled; end


  def self.from_email_list
    Ish::EmailCampaign.from_email_list
  end

  ## like belongs_to to_lead , but Lead is SQL to just the lead_id
  field :lead_id, type: :integer
  def lead; Lead.find( lead_id ); end
  def to_email; lead[:email]; end ## @TODO: remove, just use the lead. _vp_ 2023-03-27


  ##
  ## For tracking / utm
  ##
  attr_reader :tid

  def get_binding
    @lead = lead()
    binding()
  end

  def self.summary
    pipeline = [
      { '$group' => {
        '_id' => { '$dateToString' => { 'format' => "%Y-%m-%d", 'date' => "$sent_at" } }, 'total' => { '$sum' => 1 }
      } },
      { '$sort' => { '_id': -1 } },
    ]
    outs = Ish::EmailContext.collection.aggregate( pipeline )
    outs.to_a
  end

end
Ctx = ::Ish::EmailContext

