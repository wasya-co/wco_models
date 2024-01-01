
class Wco::Lead
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leads'

  field :email
  validates :email, presence: true, uniqueness: true
  index({ email: -1 })

  belongs_to :leadset, class_name: 'Wco::Leadset'

  has_and_belongs_to_many :conversations, class_name: 'WcoEmail::Conversation'

  def self.list
    all.map { |p| [ p.id, p.email ] }
  end

end
