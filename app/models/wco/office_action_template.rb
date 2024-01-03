class Wco::OfficeActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_office_action_templates'

  field :slug
  validates :slug, presence: true, uniqueness: true

  belongs_to :from,      polymorphic: true
  belongs_to :publisher, class_name: 'Wco::Publisher'

  field :period
  field :kind

end
