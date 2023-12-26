
class Wco::Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leads'

end
