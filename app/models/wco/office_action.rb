
class Wco::OfficeAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_office_actions'

  field     :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true

  # field :descr, type: :string ## optional

  belongs_to :office_action_template, inverse_of: :office_action
  def tmpl
    office_action_template
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSS         = [ STATUS_ACTIVE, STATUS_INACTIVE ]
  field :status, type: :string
  scope :active, ->{ where( status: STATUS_ACTIVE ) }

  field :perform_at, type: :time

  def do_run
    sch = self
    sch.update!({ status: STATUS_INACTIVE })

    eval( sch.tmpl.action_exe )

    # schedule next actions & update the action
    sch.tmpl.ties.each do |tie|
      next_sch = self.class.find_or_initialize_by({
        office_action_template_id: tie.next_tmpl.id,
      })
      next_sch.perform_at = eval(tie.next_at_exe)
      next_sch.status     = STATUS_ACTIVE
      next_sch.save!
    end
  end

  def to_s
    slug
  end
end
OA ||= Wco::OfficeAction
