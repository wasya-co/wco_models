
class Wco::Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_tags'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: -1 })

  belongs_to :parent, class_name: '::Wco::Tag', inverse_of: :sons, optional: true
  has_many :sons,     class_name: '::Wco::Tag', inverse_of: :parent

  belongs_to :site,          class_name: '::Wco::Site', optional: true
  has_many :email_filters,   class_name: '::WcoEmail::EmailFilter',   inverse_of: :tag
  has_many :email_templates, class_name: '::WcoEmail::EmailTemplate', inverse_of: :tag
  has_many :abjects,         class_name: '::WcoEmail::EmailFilterAction', inverse_of: :abject

  has_and_belongs_to_many :conversations, class_name: '::WcoEmail::Conversation', index: true
  has_and_belongs_to_many :galleries,     class_name: '::Wco::Gallery'
  has_and_belongs_to_many :leads,         class_name: '::Wco::Lead',    index: true
  has_and_belongs_to_many :leadsets,      class_name: '::Wco::Leadset'
  has_many :logs, inverse_of: :obj
  has_and_belongs_to_many :message_stubs, class_name: '::WcoEmail::MessageStub'
  has_and_belongs_to_many :newsvideos, class_name: '::Wco::Newsvideo'
  has_and_belongs_to_many :reports,    class_name: '::Wco::Report'
  has_and_belongs_to_many :videos,     class_name: '::Wco::Video'



  INBOX = 'inbox'
  def self.inbox
    find_or_create_by({ slug: INBOX })
  end

  SPAM = 'spam'
  def self.spam
    find_or_create_by({ slug: SPAM })
  end

  NOT_SPAM = 'not-spam'
  def self.not_spam
    find_or_create_by({ slug: NOT_SPAM })
  end

  TRASH = 'trash'
  def self.trash
    find_or_create_by({ slug: TRASH })
  end

  def to_s
    slug
  end
  def self.list
    [[nil,nil]] + all.order_by( slug: :asc ).map { |p| [ p.slug, p.id ] }
  end
end
