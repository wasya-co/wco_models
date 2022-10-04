
class Ish::EmailUnsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  validates_presence_of :email
  validates_uniqueness_of :email

  field :mailer_type

  field :reason

  field :unsubscribed_at



end

