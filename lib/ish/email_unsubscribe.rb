
class Ish::EmailUnsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email
  # validates_presence_of :email
  # validates_uniqueness_of :email

  field :lead_id
  field :reason
  field :unsubscribed_at

  belongs_to :campaign, class_name: '::Ish::EmailCampaign', inverse_of: :unsubscribes
  belongs_to :template, class_name: '::Ish::EmailTemplate', inverse_of: :unsubscribes


end

