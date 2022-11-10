
#
# This looks like it sends a single email?
#

class Ish::EmailContext
  include Mongoid::Document
  include Mongoid::Timestamps

  PAGE_PARAM_NAME = 'email_contexts_page'

  FROM_EMAILS = %w| piousbox@gmail.com victor@piousbox.com victor@wasya.co no-reply@piousbox.com |
  field :from_email
  validates_presence_of :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  field :to_email
  validates_presence_of :to_email

  field :subject
  validates_presence_of :subject

  field :body
  # validates_presence_of :body ## With plain type, there is no body but there are variables for templating.

  belongs_to :email_template

  field :rendered_str

  field :sent_at, type: DateTime

  #
  # For templating:
  #
  field :name

end
EmailContext = Ish::EmailContext
