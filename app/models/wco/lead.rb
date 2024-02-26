
class Wco::Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_leads'

  field :email
  validates :email, presence: true, uniqueness: true
  index({ email: -1 }, { unique: true })

  field :name
  field :phone
  field :address

  belongs_to :leadset, class_name: 'Wco::Leadset'
  before_validation :set_leadset, on: :create
  def set_leadset
    domain         = email.split('@')[1]
    self.leadset ||= Wco::Leadset.find_or_create_by({ company_url: domain })
  end
  before_validation :normalize_email, on: :create
  def normalize_email
    self[:email] = email.downcase
    if email.index('+')
      a = email
      a.slice!( a[a.index('+')...a.index('@')] )
      self[:email] = a
    end
  end
  def self.normalize_email a
    a = a.downcase
    if a.index('+')
      a.slice!( a[a.index('+')...a.index('@')] )
    end
    return a
  end
  def self.find_or_create_by_email email
    email = self.normalize_email email
    out = where( email: email ).first
    if !out
      domain    = email.split('@')[1]
      leadset   = Wco::Leadset.where(  company_url: domain ).first
      leadset ||= Wco::Leadset.create( company_url: domain, email: email )
      out = create!( email: email, leadset: leadset )
    end
    return out
  end


  has_one :photo,      class_name: 'Wco::Photo'

  has_many                :email_messages,          class_name: '::WcoEmail::Message', inverse_of: :lead

  has_and_belongs_to_many :conversations,           class_name: '::WcoEmail::Conversation', index: true
  def convs; conversations; end
  has_many                :email_contexts,          class_name: '::WcoEmail::Context'
  def ctxs; email_contexts; end
  has_many                :email_actions,           class_name: '::WcoEmail::EmailAction'
  def schs; email_actions; end
  has_and_belongs_to_many :email_campaigns,         class_name: '::WcoEmail::Campaign'
  has_and_belongs_to_many :tags,                    class_name: '::Wco::Tag', index: true

  # has_many :galleries, class_name: 'Wco::Gallery'
  # has_many :videos, class_name: 'Wco::Video'

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

  def to_s
    "#{name} <#{email}>"
  end
  def self.list
    [[nil,nil]] + all.map { |p| [ p.email, p.id ] }
  end
end
