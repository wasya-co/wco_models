
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leadsets'

  field     :company_url
  validates :company_url, presence: true, uniqueness: true
  index({ company_url: 1 }, { name: 'company_url' })

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, uniqueness: { allow_nil: true } # presence: true

  has_many :leads,         class_name: 'Wco::Lead'
  has_many :profiles,      class_name: 'Wco::Profile',           inverse_of: :leadset
  has_many :appliances,    class_name: 'WcoHosting::Appliance',  inverse_of: :leadset
  has_many :subscriptions, class_name: 'Wco::Subscription',      inverse_of: :leadset

  has_and_belongs_to_many :serverhosts, class_name: 'WcoHosting::Serverhost' # , inverse_of: :leadset
  def next_serverhost
    serverhosts.first
  end

  ##
  ## stripe
  ##
  field :customer_id
  def customer_id
    if self[:customer_id].blank?
      return nil if !email
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

end
