
class WcoHosting::Domain
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_dns_domains'

  field :name
  validates :name, presence: true, uniqueness: true

  ## orbital.city         : Z0145070C3DD1OJWHTXJ
  ## oquaney-splicing.com : Z060228025Y0JHUA35GN5
  field :route53_zone
  validates :route53_zone, presence: true

  STATE_ACTIVE   = 'active'
  STATE_INACTIVE = 'inactive'
  STATES = [ 'active', 'inactive' ]
  field :state, default: STATE_ACTIVE

  def self.list
    [[nil,nil]] + all.where({ state: STATE_ACTIVE }).map { |i| [i.name, i.name ] }
  end

end