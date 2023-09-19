
class Office::ObfuscatedRedirect
  include Mongoid::Document
  include Mongoid::Timestamps

  field :to,     type: :string
  validates :to, presence: true

  field :visited_at, type: DateTime
  field :visits, type: :array, default: []

end
