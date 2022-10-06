
#
# This looks like it sends a single email?
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  PAGE_PARAM_NAME = 'email_contexts_page'

  field :to_email
  validates_presence_of :to_email

  field :subject
  validates_presence_of :subject

  field :body
  validates_presence_of :body

  belongs_to :email_template

  field :rendered_str

  field :sent_at, type: DateTime

end
EmailContext = Ish::EmailContext
