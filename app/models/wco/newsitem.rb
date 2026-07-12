
##
## not used?! there is no collection _vp_ 2026-07-12
##
class Wco::Newsitem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_newsitems'

  belongs_to :profile, class_name: 'Wco::Profile', optional: true
end
