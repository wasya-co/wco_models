
class WcoHosting::Domain
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_dns_domains'

  field :name
  validates :name, presence: true, uniqueness: true

  has_many :subdomains, class_name: 'WcoHosting::Subdomain'

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ 'active', 'inactive' ]
  field :status
  scope :active, ->{ where(status: STATUS_ACTIVE) }

  def to_s
    name
  end
  def self.list
    [[nil,nil]] + active.map { |i| [i.name, i.name ] }
  end
end