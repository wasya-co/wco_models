
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_leadsets'

  PAGE_PARAM_NAME = 'leadsets_page'

  field     :company_url
  validates :company_url, presence: true, uniqueness: true
  index({ company_url: 1 }, { unique: true, name: 'company_url' })
  before_validation :normalize_company_url, on: :create
  def normalize_company_url
    company_url.downcase!
  end
  def domain; company_url; end # for anti-spam
  def self.from_email email
    _domain = email.split('@')[1]
    words = _domain.split('.')
    if %w| com net gov org |.include?( words[-2] )
      words = words[-3, 3]
    else
      words = words[-2, 2]
    end
    _domain = words.join('.')
    find_or_create_by( company_url: _domain )
  end



  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, uniqueness: { allow_nil: true } # presence: true


  has_many :appliances,      class_name: '::WcoHosting::Appliance',   inverse_of: :leadset
  has_many :appliance_tmpls, class_name: 'Wco::Price', inverse_of: :leadset

  has_many :environments,  class_name: '::WcoHosting::Environment', inverse_of: :leadset
  has_many :invoices,      class_name: 'Wco::Invoice'
  has_many :leads,         class_name: 'Wco::Lead'
  # has_many :subdomains,    class_name: 'WcoHosting::Subdomain'

  has_many :profiles,      class_name: 'Wco::Profile',              inverse_of: :leadset
  has_many :subscriptions, class_name: 'Wco::Subscription',         inverse_of: :leadset
  has_and_belongs_to_many :conversations, class_name: '::WcoEmail::Conversation', index: true
  def convs; conversations; end
  has_and_belongs_to_many :tags,          class_name: 'Wco::Tag'
  has_and_belongs_to_many :email_filters, class_name: 'WcoEmail::EmailFilter'


  field :next_invoice_number, type: :integer, default: 100
  field :mangle_subject, type: :boolean, default: false

  has_and_belongs_to_many :serverhosts, class_name: '::WcoHosting::Serverhost' # , inverse_of: :leadset
  def next_serverhost
    serverhosts.first
  end


  ##
  ## stripe
  ##
  field :customer_id
  def customer_id
    if self[:customer_id].blank?
      return nil if !email.present?
      existing = Stripe::Customer.search({ query: "email: '#{email}'" })
      if existing.data.present?
        update_attributes( customer_id: existing.data[0][:id] )
      else
        customer = Stripe::Customer.create({ email: email })
        update_attributes( customer_id: customer[:id] )
      end
    end
    self[:customer_id]
  end

  def to_s
    company_url
  end
  def self.list
    [[nil,nil]] + all.map { |ttt| [ ttt.company_url, ttt.id ] }
  end
end
