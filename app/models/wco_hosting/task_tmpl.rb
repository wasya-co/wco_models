
##
## not used? no collection
##
class WcoHosting::TaskTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_task_tmpls'

  field :slug
  validates :slug, presence: true

  has_many :tasks, class_name: 'WcoHosting::Task'
  has_and_belongs_to_many :appliance_tmpls, class_name: 'WcoHosting::ApplianceTmpl'

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |t| [t, t.id] }
  end
end
