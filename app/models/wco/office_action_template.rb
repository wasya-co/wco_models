class Wco::OfficeActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_office_action_templates'

end
