
class WcoHosting::Subdomain
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_dns_subdomains'

  field :name
  validates :name, presence: true, uniqueness: { scope: :domain_id }

  belongs_to :domain,  class_name: 'WcoHosting::Domain'
  belongs_to :leadset, class_name: 'Wco::Leadset'

  # STATUS_ACTIVE   = 'active'
  # STATUS_INACTIVE = 'inactive'
  # STATUSES        = [ 'active', 'inactive' ]
  # field :status
  # scope :active, ->{ where(status: STATUS_ACTIVE) }

  # def self.list
  #   [[nil,nil]] + active.map { |i| [i.name, i.name ] }
  # end
end

