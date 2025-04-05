
class Wco::LeadsetApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_leadset_appliance_tmpls'

  belongs_to :leadset,        class_name: 'Wco::Leadset'
  belongs_to :appliance_tmpl, class_name: 'WcoHosting::ApplianceTmpl'
  has_one :price, class_name: 'Wco::Price'


end


