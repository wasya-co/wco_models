
class Ish::Unsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  validates_presence_of :email
  validates_uniqueness_of :email

  field :reason

  field :mailer_type

end

