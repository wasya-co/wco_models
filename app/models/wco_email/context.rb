
##
## Send a single email
##
class WcoEmail::Context
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_email_contexts'

  PAGE_PARAM_NAME = 'email_contexts_page'


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
  ## Looks good... 2024-01-17
  def body
    if self[:body].presence
      return self[:body]
    else
      return tmpl&.body || ''
    end
  end
  before_validation :clear_body
  def clear_body
    tmp = ActionView::Base.full_sanitizer.sanitize body
    if tmp.blank?
      self[:body] = nil
    end
  end


  field :from_email
  def from_email
    if self[:from_email].presence
      return self[:from_email]
    elsif tmpl&.from_email
      return tmpl.from_email
    else
      return DEFAULT_FROM_EMAIL
    end
  end

  field :subject
  def subject
    self[:subject].presence || tmpl&.subject
  end

  belongs_to :reply_to_message, class_name: 'WcoEmail::Message', inverse_of: :replies, optional: true

  belongs_to :email_template, class_name: 'WcoEmail::EmailTemplate'
  def tmpl; email_template; end

  belongs_to :email_action, class_name: 'WcoEmail::EmailAction', optional: true
  def sch; email_action; end

  belongs_to :email_campaign, class_name: 'WcoEmail::EmailCampaign', optional: true

  field :rendered_str

  field :sent_at,         type: DateTime
  field :send_at,         type: DateTime
  field :unsubscribed_at, type: DateTime


  def self.notsent
    where( sent_at: nil, unsubscribed_at: nil )
  end

  def self.scheduled
    where( :send_at.lte => Time.now  )
  end


  belongs_to :lead,      class_name: 'Wco::Lead'
  def to_email
    lead.email
  end

  field :cc,   type: :string
  field :ccs,  type: :array, default: []
  field :bcc,  type: :string
  field :bccs, type: :array, default: []

  ##
  ## For tracking / utm
  ##
  attr_reader :tid

  def get_binding
    @lead             = lead
    @utm_tracking_str = utm_tracking_str
    # eval( tmpl.config_exe ) ## @TODO: remove? 2024-01-17
    binding()
  end

  def self.summary
    pipeline = [
      { '$group' => {
        '_id' => { '$dateToString' => { 'format' => "%Y-%m-%d", 'date' => "$sent_at", 'timezone' => 'America/Chicago' } }, 'total' => { '$sum' => 1 }
      } },
      { '$sort' => { '_id': -1 } },
    ]
    outs = WcoEmail::Context.collection.aggregate( pipeline )
    outs.to_a
  end

  def config
    OpenStruct.new JSON.parse( tmpl[:config_json] )
  end

  def utm_tracking_str
    {
      'cid'          => lead_id,
      'utm_campaign' => tmpl.slug,
      'utm_medium'   => 'email',
      'utm_source'   => tmpl.slug,
    }.map { |k, v| "#{k}=#{v}" }.join("&")
  end

  def unsubscribe_url
    Wco::Engine.routes.url_helpers.unsubscribes_url({
      host:        Rails.application.routes.default_url_options[:host],
      lead_id:     lead_id,
      template_id: tmpl.id,
      token:       lead.unsubscribe_token,
    })
  end

end
Ctx = WcoEmail::Context

