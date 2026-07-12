##
## not used? no collection
##
class WcoEmail::Config
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_config'

  field :key
  validates :key, { presence: true, uniqueness: true }

  field :value
  validates :value, { presence: true }

  field :descr

end
