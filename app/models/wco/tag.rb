
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_tags'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 })

  # parent-child

  has_many :email_filters, class_name: 'WcoEmail::EmailFilter', inverse_of: :tag

  has_and_belongs_to_many :conversations, class_name: 'WcoEmail::Conversation'
  has_and_belongs_to_many :message_stubs, class_name: 'WcoEmail::MessageStub'
  has_and_belongs_to_many :headlines # ,     class_name: 'Headline'
  has_and_belongs_to_many :leads # ,         class_name: 'Lead'
  has_and_belongs_to_many :leadsets # ,      class_name: 'Leadset'
  has_and_belongs_to_many :reports
  has_and_belongs_to_many :logs

  INBOX = 'inbox'
  def self.inbox
    find_or_create_by({ slug: INBOX })
  end

  TRASH = 'trash'
  def self.trash
    find_or_create_by({ slug: TRASH })
  end

  SPAM = 'spam'
  def self.spam
    find_or_create_by({ slug: SPAM })
  end

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.map { |p| [ p.slug, p.id ] }
  end
end
