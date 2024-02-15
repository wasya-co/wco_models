
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_leadsets'

  field     :company_url
  validates :company_url, presence: true, uniqueness: true
  index({ company_url: 1 }, { unique: true, name: 'company_url' })
  before_validation :normalize_company_url, on: :create
  def normalize_company_url
    company_url.downcase!
  end

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, uniqueness: { allow_nil: true } # presence: true


  has_many :appliances,    class_name: '::WcoHosting::Appliance',   inverse_of: :leadset
  has_many :appliance_tmpl_prices, class_name: 'Wco::Price'
  has_many :environments,  class_name: '::WcoHosting::Environment', inverse_of: :leadset
  has_many :invoices,      class_name: 'Wco::Invoice'
  has_many :leads,         class_name: 'Wco::Lead'
  has_many :subdomains,    class_name: 'WcoHosting::Subdomain'

  has_many :profiles,      class_name: 'Wco::Profile',              inverse_of: :leadset
  has_many :subscriptions, class_name: 'Wco::Subscription',         inverse_of: :leadset
  has_and_belongs_to_many :tags, class_name: 'Wco::Tag'


  field :next_invoice_number, type: :integer, default: 100

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
      # puts! existing, 'existing'
      if existing.data.present?
        update_attributes( customer_id: existing.data[0][:id] )
      else
        customer = Stripe::Customer.create({ email: email })
        # puts! customer, 'customer'
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
