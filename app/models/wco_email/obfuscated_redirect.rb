
class WcoEmail::ObfuscatedRedirect
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_obfuscated_redirects'

  field :to,     type: :string
  validates :to, presence: true

  field :visited_at, type: DateTime
  field :visits, type: :array, default: []

end
