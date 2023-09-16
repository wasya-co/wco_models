
##
## 2023-03-04 _vp_ When I receive one.
## 2023-03-04 _vp_ When I send one, forever.
##
class Office::EmailAction
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true

  field :descr, type: :string ## optional, can remove

  belongs_to :email_template, class_name: '::Ish::EmailTemplate'
  def tmpl; email_template; end

  has_many :scheduled_email_actions, class_name: '::Office::ScheduledEmailAction'
  def schs; scheduled_email_actions; end

  has_many :ties,      class_name: '::Office::EmailActionTie', inverse_of: :email_action
  has_many :prev_ties, class_name: '::Office::EmailActionTie', inverse_of: :next_email_action
  accepts_nested_attributes_for :ties

  has_many :email_filters, class_name: 'Office::EmailFilter', inverse_of: :email_action

end
EAct = Office::EmailAction
