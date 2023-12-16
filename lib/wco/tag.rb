
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_tags'

  field :slug
  # index
  # validate presence
  # validate uniqueness ?

  # parent-child


end
