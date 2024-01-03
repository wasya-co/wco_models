
require 'mongoid-paranoia'

##
## 2023-03-04 _vp_ An instance of an EmailAction.
## 2023-03-04 _vp_ An instance of an EmailActionTemplate.
##
class WcoEmail::EmailAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_scheduled_email_actions'


  STATUS_ACTIVE       = 'active'
  STATUS_INACTIVE     = 'inactive'
  STATUS_TRASH        = 'trash'
  STATUS_UNSUBSCRIBED = 'unsubscribed'
  STATUSS             = [ STATUS_ACTIVE, STATUS_INACTIVE, STATUS_UNSUBSCRIBED, STATUS_TRASH ]
  field :status, type: :string
  scope :active, ->{ where( status: STATUS_ACTIVE ) }

  belongs_to :email_action_template, class_name: 'WcoEmail::EmailActionTemplate'
  validates  :email_action_template, uniqueness: { scope: :lead }
  def tmpl; email_action_template; end
  def tmpl= k; email_action_template = k; end

  has_many :email_contexts, class_name: 'WcoEmail::Context'
  def ctxs; email_contexts; end

  field :perform_at, type: :time

  belongs_to :lead, class_name: 'Wco::Lead'
  # has_and_belongs_to_many :leads,      class_name: 'Wco::Lead'

  def send_and_roll
    sch = self
    sch.update({ status: STATUS_INACTIVE })

    # send now
    ctx = Ctx.create!({
      email_template_id:         sch.act.tmpl.id,
      from_email:                sch.act.tmpl.from_email,
      lead_id:                   sch.lead.id,
      scheduled_email_action_id: sch.act.id,
      send_at:                   Time.now,
      subject:                   sch.act.tmpl.subject,
    })

    # schedule next actions & update the action
    sch.act.ties.each do |tie|
      next_sch = Sch.find_or_initialize_by({
        lead_id:         sch.lead_id,
        email_action_id: tie.next_email_action.id,
      })
      next_sch.perform_at = eval(tie.next_at_exe)
      next_sch.status     = STATUS_ACTIVE
      next_sch.save!
    end
  end

end

