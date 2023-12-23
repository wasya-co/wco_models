

class Wco::Newsitem
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_newsitems'

  belongs_to :profile, class_name: 'Wco::Profile', optional: true
end
