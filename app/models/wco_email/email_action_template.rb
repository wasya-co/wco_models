
##
## 2023-03-04 _vp_ When I receive one.
## 2023-03-04 _vp_ When I send one, forever.
##
class WcoEmail::EmailActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_email_email_actions'

  field :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true
  index({ slug: 1 }, { unique: true, name: "slug_idx" })

  # field :from_email ## this is in email_template

  belongs_to :email_template, class_name: 'EmailTemplate'

  has_many :email_actions, class_name: 'EmailAction'

  has_many :ties,      class_name: '::WcoEmail::EmailActionTemplateTie', inverse_of: :tmpl
  has_many :prev_ties, class_name: '::WcoEmail::EmailActionTemplateTie', inverse_of: :next_tmpl
  accepts_nested_attributes_for :ties

  has_many :email_filters, class_name: 'EmailFilter', inverse_of: :email_action

  def to_s
    slug
  end

  def self.list
    [[nil,nil]] + all.map { |a| [ a.slug, a.id ] }
  end
end
