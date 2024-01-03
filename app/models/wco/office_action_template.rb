
##
## A Publisher is an OAT
##
class Wco::OfficeActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_office_action_templates'

  field :slug
  validates :slug, presence: true, uniqueness: true

  belongs_to :from,      polymorphic: true,            optional: true
  belongs_to :publisher, class_name: 'Wco::Publisher', optional: true

  field :exe, type: :string
  validates :exe, presence: true

  has_many :office_actions

  has_many :ties,      class_name: 'OfficeActionTemplateTie', inverse_of: :office_action_template
  has_many :prev_ties, class_name: 'OfficeActionTemplateTie', inverse_of: :next_office_action_template
  accepts_nested_attributes_for :ties

  def self.list
    [[nil,nil]] + all.map { |ttt| [ ttt.slug, ttt.id ] }
  end
end
