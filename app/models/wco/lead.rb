
class Wco::Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leads'

  PAGE_PARAM_NAME = 'leads_page'

  field :email
  validates :email, presence: true, uniqueness: true
  index({ email: -1 }, { unique: true })

  field :name
  # validates :name, allow_nil: true, uniqueness: true
  index({ name: -1 })
  def name
    if !self[:name].present?
      if email
        _name = (email[/\A[a-zA-Z]+/] || 'associate').capitalize
        update_attributes( name: _name )
      end
    end
    self[:name]
  end


  field :phone
  field :address
  field :comment ## _TODO: replace with log?
  field :memory, type: Hash, default: {}

  belongs_to :leadset, class_name: 'Wco::Leadset'
  before_validation :normalize_email, on: :create
  def normalize_email
    self[:email] = Wco::Lead.normalize_email email
  end
  def self.normalize_email a
    a = a.downcase
    if a.index('+')
      a.slice!( a[a.index('+')...a.index('@')] )
    end
    return a
  end
  before_validation :set_leadset, on: :create
  def set_leadset
    domain         = email.split('@')[1]
    root_domain    = PublicSuffix.domain(domain)
    self.leadset ||= Wco::Leadset.find_or_create_by({ company_url: root_domain })
  end

  def self.find_or_create_by_email email
    email = self.normalize_email email
    out   = where( email: email ).first
    out ||= create!( email: email )
  end


  has_one :photo,      class_name: 'Wco::Photo'

  has_many                :email_messages,          class_name: '::WcoEmail::Message', inverse_of: :lead

  has_and_belongs_to_many :conversations,           class_name: '::WcoEmail::Conversation', index: true
  def convs; conversations; end

  has_many :office_actions,          class_name: '::Wco::OfficeAction'

  has_many                :email_contexts,          class_name: '::WcoEmail::Context'
  def ctxs; email_contexts; end
  has_many                :email_actions,           class_name: '::WcoEmail::EmailAction'
  def schs; email_actions; end
  has_and_belongs_to_many :email_campaigns,         class_name: '::WcoEmail::Campaign'
  has_and_belongs_to_many :tags,                    class_name: '::Wco::Tag', index: true

  has_many :galleries, class_name: 'Wco::Gallery'
  has_many :videos,    class_name: 'Wco::Video'

  OP_DELETE          = 'delete'
  OP_ADD_TO_CAMPAIGN = 'add_to_campaign'
  OPS                = [ OP_DELETE, OP_ADD_TO_CAMPAIGN ]

  has_many :unsubscribes, class_name: '::WcoEmail::Unsubscribe'
  field :unsubscribe_token
  def unsubscribe_token
    if !self[:unsubscribe_token]
      update_attributes({ unsubscribe_token: (0...8).map { (65 + rand(26)).chr }.join })
    end
    self[:unsubscribe_token]
  end
  field :unsubscribed_at

  def to_s
    # "`#{name}` <#{email}>"
    email
  end
  def self.list
    [[nil,nil]] + all.map { |p| [ p.email, p.id ] }
  end
end
