
#
# This looks like it sends a single email?
#

class Ish::Office::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  field :to_email
  field :subject
  field :template_name

  # sent_at ?
  # rendered_str ?

end
EmailContext = Ish::Office::EmailContext
