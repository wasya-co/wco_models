
class Wco::EmailConversationLead
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :email_conversation, class_name: 'Office::EmailConversation'
  belongs_to :wco_lead,           class_name: 'Ish::UserProfile'


end
