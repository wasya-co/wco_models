
require 'wco/ai_writer'

##
## A Publisher is an OAT
##
class Wco::OfficeActionTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_office_action_templates'

  field :slug
  validates :slug, presence: true, uniqueness: true

  belongs_to :from,      polymorphic: true,            optional: true
  belongs_to :publisher, class_name: 'Wco::Publisher', optional: true

  field :action_exe, type: :string
  validates :action_exe, presence: true
  def do_run
    eval( action_exe )
  end

  has_many :office_actions, inverse_of: :office_action_template
  def actions; office_actions; end

  has_many :ties,      class_name: 'OfficeActionTemplateTie', inverse_of: :office_action_template
  has_many :prev_ties, class_name: 'OfficeActionTemplateTie', inverse_of: :next_office_action_template
  accepts_nested_attributes_for :ties

  def to_s
    "#{slug}"
  end

  def self.list
    [[nil,nil]] + all.map { |ttt| [ ttt.slug, ttt.id ] }
  end

end
OAT ||= Wco::OfficeActionTemplate
