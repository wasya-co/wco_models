
class Office::ActionTie
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_action_ties'

  attr_accessor :to_delete

  belongs_to :office_action,      class_name: '::Office::Action', inverse_of: :ties
  belongs_to :next_office_action, class_name: '::Office::Action', inverse_of: :prev_ties

  field :next_at_exe,     type: :string
  validates :next_at_exe, presence: true

end
OActie = Office::ActionTie
