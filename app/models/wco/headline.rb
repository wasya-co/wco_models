

class Wco::Headline
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_content_headlines'

  field :date
  validates :date, presence: true

  field :name
  validates :name, presence: true, uniqueness: true

  belongs_to :site, class_name: 'Wco::Site'

  has_and_belongs_to_many :tags, class_name: 'Wco::Tag'

end