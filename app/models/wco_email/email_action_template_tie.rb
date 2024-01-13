
class WcoEmail::EmailActionTemplateTie
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_email_action_template_tie'

  attr_accessor :to_delete

  belongs_to :tmpl,      class_name: 'EmailActionTemplate', inverse_of: :ties
  belongs_to :next_tmpl, class_name: 'EmailActionTemplate', inverse_of: :prev_ties

  field     :next_at_exe, type: :string
  validates :next_at_exe, presence: true

end
