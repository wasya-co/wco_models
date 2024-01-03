
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_tags'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 })

  # parent-child

  has_and_belongs_to_many :conversations, class_name: 'WcoEmail::Conversation'
  has_and_belongs_to_many :message_stubs, class_name: 'WcoEmail::MessageStub'
  has_and_belongs_to_many :leads,         class_name: 'Wco::Lead'
  has_and_belongs_to_many :leadsets,      class_name: 'Wco::Leadset'

  INBOX = 'inbox'
  TRASH = 'trash'

  def self.list
    [[nil,nil]] + all.map { |p| [ p.slug, p.id ] }
  end

end
