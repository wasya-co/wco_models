
class Wco::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kind
  validates :kind, presence: true

  field :environment

  field :name
  validates :name, uniqueness: { scope: :leadset_id }, presence: true

  # field :service_name
  def service_name
    # "#{@appliance[:kind]}_#{@appliance[:environment]}_#{@appliance[:name]}"
    "#{kind}_#{environment}_#{name}"
  end


  field :subdomain
  field :domain
  def origin
    "#{subdomain}.#{domain}"
  end

  field :leadset_id # old sql
  belongs_to :leadset, class_name: 'Wco::Leadset', inverse_of: :appliances

  belongs_to :appliance_tmpl, class_name: 'Wco::ApplianceTmpl'
  def tmpl
    appliance_tmpl
  end

  belongs_to :serverhost,     class_name: 'Wco::Serverhost'


  field :port

  STATE_PENDING = 'state-pending'
  STATE_LIVE    = 'state-live'
  STATE_TERM    = 'state-term'
  STATES = %w| state-pending state-live state-term |
  field :state, default: STATE_PENDING

  def route53_zone
    Wco::DnsDomain.find_by({ name: domain })[0].route53_zone
  end

end


