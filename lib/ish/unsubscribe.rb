
class Ish::Unsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  field :unsubscribed_at
  field :reason

end

