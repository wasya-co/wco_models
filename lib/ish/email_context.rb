
class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  field :to_email
  field :subject
  field :template_name

end
EmailContext = Ish::EmailContext
