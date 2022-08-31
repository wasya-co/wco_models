
class Ish::Meeting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :datetime, type: DateTime
  field :invitee_email, type: String
  field :invitee_name, type: String
  field :timezone, type: String, default: 'Central Time (US & Canada)'
  field :template_name

  field :send_reminder_morning, type: Boolean, default: false
  field :send_reminder_15min,  type: Boolean, default: false

  def self.template_name_options
    [
      [ '', '' ],
      ['calendly_meeting_v1', 'calendly_meeting_v1'],
      ['calendly_meeting_v2', 'calendly_meeting_v2'],
    ]
  end

  def host_name
    'Victor Puudeyev'
  end

  def host_email
    'piousbox@gmail.com'
  end

end
