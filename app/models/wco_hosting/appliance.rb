
class WcoHosting::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_appliances'

  has_many :logs, as: :obj, class_name: 'Wco::Log'

  belongs_to :leadset,      class_name: 'Wco::Leadset', inverse_of: :appliances
  belongs_to :subscription, class_name: 'Wco::Subscription' # , inverse_of: :appliance

  field :service_name
  before_validation :set_service_name, on: :create, unless: ->{ service_name }
  def set_service_name
    self[:service_name] = host.gsub(".", "_")
  end

  belongs_to :environment, class_name: 'WcoHosting::Environment', inverse_of: :appliances, optional: true

  field :subdomain
  field :domain
  def host
    "#{subdomain}.#{domain}"
  end

  field :n_retries, type: :integer, default: 3

  belongs_to :appliance_tmpl, class_name: 'WcoHosting::ApplianceTmpl'
  def tmpl
    appliance_tmpl
  end
  def kind
    tmpl.kind
  end

  belongs_to :serverhost,  class_name: 'WcoHosting::Serverhost'

  field :port

  STATE_PENDING = 'state-pending'
  STATE_LIVE    = 'state-live'
  STATE_TERM    = 'state-term'
  field :state, default: STATE_PENDING

  def to_s
    service_name
  end
end


