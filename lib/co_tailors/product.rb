
class CoTailors::Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :cost,        :type => Integer
  field :title,       :type => String
  field :description, :type => String

  KINDS = %w( shirt pants suit )
  field :kind,        :type => String

end

