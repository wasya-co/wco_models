
class Wco::OfficeActionTemplateTie
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_office_action_template_ties'

  attr_accessor :to_delete

  belongs_to :office_action_template,      class_name: 'OfficeActionTemplate', inverse_of: :ties
  def tmpl; office_action_template; end

  belongs_to :next_office_action_template, class_name: 'OfficeActionTemplate', inverse_of: :prev_ties
  def next_tmpl; next_office_action_template; end
  # def tmpl;     next_office_action_template; end


  field :next_at_exe, type: :string
  validates :next_at_exe, presence: true

end
