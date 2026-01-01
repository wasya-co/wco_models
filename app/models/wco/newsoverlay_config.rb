
class Wco::NewsoverlayConfig
  include Mongoid::Document
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'wco_newsoverlay_configs'

  PAGE_PARAM_NAME = 'newsoverlayconfigs_page'

  belongs_to :video
  belongs_to :newsvideo

end
