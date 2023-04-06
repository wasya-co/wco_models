
##
## 2023-03-04 _vp_ An instance of an EmailAction.
##
class Office::ScheduledEmailAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_scheduled_email_actions'

  field :lead_id, type: :integer
  def lead
    Lead.find( lead_id )
  end

  STATE_ACTIVE   = 'active'
  STATE_INACTIVE = 'inactive'
  STATES         = [ STATE_ACTIVE, STATE_INACTIVE ]
  field :state, type: :string
  scope :active, ->{ where( state: STATE_ACTIVE ) }

  belongs_to :email_action, class_name: '::Office::EmailAction'
  validates  :email_action, uniqueness: { scope: :lead_id }
  def act;    email_action;    end
  def act= a; email_action= a; end

  has_many :email_contexts, class_name: '::Ish::EmailContext'
  def ctxs; email_contexts; end

  field :perform_at, type: :time

  def send_and_roll
    sch = self
    sch.update_attributes({ state: Sch::STATE_INACTIVE })

    # send now
    ctx = Ctx.create!({
      email_template_id: sch.act.tmpl.id,
      lead_id: sch.lead.id,
      send_at: Time.now,
      subject: sch.act.tmpl.subject,
      from_email: sch.act.tmpl.from_email,
      scheduled_email_action_id: sch.act.id,
    })

    # schedule next actions & update the action
    sch.act.ties.each do |tie|
      next_act = tie.next_email_action
      next_at  = eval(tie.next_at_exe)
      next_sch = Sch.find_or_initialize_by({
        lead_id: sch.lead_id,
        email_action_id: next_act.id,
      })
      next_sch.perform_at = next_at
      next_sch.state      = Sch::STATE_ACTIVE
      next_sch.save!
    end
  end

end
::Sch = Office::ScheduledEmailAction

