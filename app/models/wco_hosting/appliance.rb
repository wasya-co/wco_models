
class WcoHosting::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_appliances'

  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :appliances

  field :service_name
  before_validation :set_service_name, on: :create, unless: ->{ service_name }
  def set_service_name
    self[:service_name] = host.gsub(".", "_")
  end

  field :environment

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

end


