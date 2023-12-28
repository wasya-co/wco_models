
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_tags'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 })

  # parent-child

  has_and_belongs_to_many :conversations, class_name: 'WcoEmail::Conversation'

  INBOX = 'inbox'
  TRASH = 'trash'

end
