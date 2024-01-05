

class Wco::Log
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_logs'

  field :message

  field :class_name
  field :object_id

  field :raw_json, type: Object, default: '{}'

  has_and_belongs_to_many :tags

end
