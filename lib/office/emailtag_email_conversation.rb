
class Office::EmailtagEmailConversation
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :emailtag,           class_name: 'Office::Emailtag'
  belongs_to :email_conversation, class_name: 'Office::EmailConversation'

end
EmailtagTie = Office::EmailtagEmailConversation
