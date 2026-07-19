
##
## not used? no collection
##
class WcoHosting::File
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_hosting_files'

  belongs_to :serverhost, class_name: 'WcoHosting::Serverhost'
  belongs_to :appliance,  class_name: 'WcoHosting::Appliance'

  field :path,         type: :string
  field :template_erb, type: :string
  field :pre_exe,      type: :string
  field :post_exe,     type: :string

end
