
##
## act = Act.new ; tie = Actie.new; act.ties.push( tie )
##
class Office::EmailActionTie
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :to_delete

  belongs_to :email_action,      class_name: '::Office::EmailAction', inverse_of: :ties
  belongs_to :next_email_action, class_name: '::Office::EmailAction', inverse_of: :prev_ties


  field :next_at_exe, type: :string
  validates :next_at_exe, presence: true

  # field :next_in_days, type: :string
  # field :next_at_time, type: :string

  # field :slug, type: :string
  # validates :slug, uniqueness: true, allow_nil: true

  # field :descr, type: :string ## optional, can remove

  # belongs_to :email_template, class_name: '::Ish::EmailTemplate'
  # def tmpl; email_template; end

  # belongs_to :prev_email_action, class_name: '::Office::EmailAction', optional: true, inverse_of: :next_email_actions
  # has_many :next_email_actions, class_name: '::Office::EmailAction', inverse_of: :prev_email_action
  # accepts_nested_attributes_for :next_email_actions

  # has_many :scheduled_email_actions, class_name: '::Office::ScheduledEmailAction'
  # def schs; scheduled_email_actions; end

end
Actie = Office::EmailActionTie
