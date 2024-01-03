
##
## 2023-03-04 _vp_ When I receive one.
## 2023-03-04 _vp_ When I send one, forever.
##
class WcoEmail::EmailActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_email_actions'

  field :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true
  index({ slug: 1 }, { unique: true, name: "slug_idx" })

  belongs_to :email_template, class_name: 'WcoEmail::EmailTemplate'
  def tmpl; email_template; end

  has_many :scheduled_email_actions, class_name: 'WcoEmail::ScheduledEmailAction'
  def schs; scheduled_email_actions; end

  has_many :ties,      class_name: 'WcoEmail::EmailActionTie', inverse_of: :email_action
  has_many :prev_ties, class_name: 'WcoEmail::EmailActionTie', inverse_of: :next_email_action
  accepts_nested_attributes_for :ties

  has_many :email_filters, class_name: 'WcoEmail::EmailFilter', inverse_of: :email_action

  ## @TODO: change this right now.
  field :deleted_at, default: nil, type: :time

  def self.list
    [[nil,nil]] + WcoEmail::EmailAction.where({ :deleted_at => nil }).map { |a| [ a.slug, a.id ] }
  end

end
