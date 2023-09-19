
##
## The obfuscated action
##
class Office::LeadAction
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :lead_action_template, class_name: '::Office::LeadActionTemplate', inverse_of: :lead_actions, foreign_key: :tmpl_id

  field     :lead_id, type: :integer
  validates :lead_id, presence: true
  def lead
    Lead.find( lead_id )
  end

  field :params, type: Object


end

