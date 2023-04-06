
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

end
EActie = Office::EmailActionTie
