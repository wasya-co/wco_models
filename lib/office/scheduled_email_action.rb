
##
## 2023-03-04 _vp_ An instance of an EmailAction.
##
class Office::ScheduledEmailAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

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
  def act; email_action; end
  def act= a; email_action= a; end
  validates :email_action, uniqueness: { scope: :lead_id }

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

## @TODO: herehere 2023-03-04 _vp_ Currently Working on this
=begin
::Sch.active.where( :perform_at.lte => Time.now ) do |sch|
  next_a = sch.next_email_action

  if sch.next_actions.present?
    sch.next_actions.each do |next_a|
      next_sch_a = ::Office::ScheduledEmailAction.new({
        email_action: next_a

      next_time = Time.now + eval( sch.next_in_days )
      next_time.time = eval( sch.next_at_time )
      sch.update_attribute( :perform_at, next_time )
    end
  else
    sch.update_attribute( state: STATE_INACTIVE )
  end
=end


