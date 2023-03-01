
class Office::ScheduledEmail
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  field :lead_id, type: :string
  def lead
    Lead.find lead_id
  end

  field :interval

  belongs_to :email_template, class_name: '::Ish::EmailTemplate'
  def template
    email_template
  end

  # field :state, type: :string

  field :next_at ## Only invoke this schedule once this rolling timestamp occurs.

  has_many :email_contexts, class_name: '::Ish::EmailContext'

end
Sch = Office::ScheduledEmail


