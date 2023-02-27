
class Office::EmailConversation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :subject
  field :message_id

  field :participants, type: Array, default: []
  def participants
    return self[:participants] if self[:participants].length > 1

    tmp = email_messages.map { |e| e.from }.uniq.sort
    update_attributes( participants: tmp )
    return tmp
  end

  has_many :email_messages
  def email_messages
    Office::EmailMessage.where( email_conversation_id: self.id )
  end

  field :latest_date
  def latest_date
    return self[:latest_date] if self[:latest_date]

    tmp = email_messages.order_by( date: :desc ).first.date
    update_attributes( latest_date: tmp )
    return tmp
  end

end

