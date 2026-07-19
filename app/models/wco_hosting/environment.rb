
class WcoHosting::Environment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'wco_environments'

  belongs_to :leadset,      class_name: 'Wco::Leadset', inverse_of: :environments

  field :name
  validates :name, presence: true, uniqueness: true
  index({ name: -1 }, { unique: true })

  has_many :appliances, class_name: 'WcoHosting::Appliance', inverse_of: :environments

  ## variable @env in execution environments
  field :env_json, type: Object, default: '{}'


  def to_s
    name
  end
end


