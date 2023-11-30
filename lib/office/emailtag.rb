
class Office::Emailtag
  include Mongoid::Document
  include Mongoid::Timestamps

  # field :name
  # validates :name, presence: true

  field :slug
  validates :slug, presence: true

  INBOX = 'inbox'
  TRASH = 'trash'
  EMAILTAGS = [ INBOX, TRASH ]

  def self.inbox
    Office::Emailtag.find_by({ slug: INBOX })
  end

  def self.trash
    Office::Emailtag.find_by({ slug: TRASH })
  end

  has_many :emailtag_ties, class_name: 'Office::EmailtagEmailConversation'

end
Tag = Office::Emailtag
