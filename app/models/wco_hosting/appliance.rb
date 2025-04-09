
class WcoHosting::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_appliances'

  # field :slug, type: String
  def slug
    "#{subdomain}_#{domain.name.gsub('.', '_')}"
  end

  has_many :logs, as: :obj, class_name: 'Wco::Log'
  has_many :files,          class_name: 'WcoHosting::File'

  field :rc_json, type: Object, default: '{}'
  def rc
    OpenStruct.new JSON.parse rc_json
  end

  field :port

  belongs_to :leadset,      class_name: 'Wco::Leadset', inverse_of: :appliances
  belongs_to :subscription, class_name: 'Wco::Subscription', optional: true # , inverse_of: :appliance

  belongs_to :environment, class_name: 'WcoHosting::Environment', inverse_of: :appliances, optional: true
  def environment_name
    environment&.name
  end

  field :subdomain
  belongs_to :domain, class_name: 'WcoHosting::Domain', optional: true
  def host
    "#{subdomain}.#{domain.name}"
  end

  field :n_retries, type: :integer, default: 3

  belongs_to :appliance_tmpl, class_name: 'WcoHosting::ApplianceTmpl'
  def tmpl
    appliance_tmpl
  end
  delegate :kind, to: :appliance_tmpl

  belongs_to :serverhost,  class_name: 'WcoHosting::Serverhost', optional: true


  STATE_PENDING    = 'pending'
  STATE_LIVE       = 'live'
  STATE_TERMINATED = 'terminated'
  field :state, default: STATE_PENDING

  field :stdout, default: ''
  field :stderr, default: ''

  def to_s
    appliance_tmpl # kind
  end
end


