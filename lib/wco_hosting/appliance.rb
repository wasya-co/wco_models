
class WcoHosting::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_appliances'

  field :name
  validates :name, uniqueness: { scope: :leadset }, presence: true
  before_validation :set_name, on: :create, unless: ->{ name }
  def set_name
    name = "#{Time.now.strftime('%Y%m%d')}-#{(0...8).map { (65 + rand(26)).chr }.join}"
  end

  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :appliances




  field :kind

  field :service_name
  field :environment

  field :subdomain
  field :domain
  def host
    "#{subdomain}.#{domain}"
  end

  belongs_to :appliance_tmpl, class_name: 'Wco::ApplianceTmpl'
  def tmpl
    appliance_tmpl
  end

  belongs_to :serverhost,     class_name: 'Wco::Serverhost'
  belongs_to :wco_leadset, class_name: 'Wco::Leadset', inverse_of: :appliances

  # field :ip
  field :port

  STATE_PENDING = 'state-pending'
  STATE_LIVE    = 'state-live'
  STATE_TERM    = 'state-term'
  field :state, default: STATE_PENDING

end


