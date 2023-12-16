
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  # index
  # validate presence
  # validate uniqueness ?

  # parent-child


end
