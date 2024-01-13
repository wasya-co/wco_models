
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
  STATUSES            = [ nil, STATUS_ACTIVE, STATUS_INACTIVE, STATUS_UNSUBSCRIBED, STATUS_TRASH ]
  field :status, type: :string
  scope :active, ->{ where( status: STATUS_ACTIVE ) }

  belongs_to :lead, class_name: 'Wco::Lead'

  belongs_to :email_action_template, class_name: 'WcoEmail::EmailActionTemplate'
  validates  :email_action_template, uniqueness: { scope: :lead }
  def tmpl; email_action_template; end

  has_many :email_contexts, class_name: 'WcoEmail::Context'
  def ctxs; email_contexts; end

  field :perform_at, type: :time


  def send_and_roll
    sch = self
    sch.update({ status: STATUS_INACTIVE })

    # send now
    ctx = WcoEmail::Context.create!({
      email_action:   sch,
      email_template: sch.tmpl.email_template,
      from_email:     sch.tmpl.email_template.from_email,
      lead:           sch.lead,
      send_at:        Time.now,
      subject:        sch.tmpl.email_template.subject,
    })

    # schedule next actions & update the action
    sch.tmpl.ties.each do |tie|
      next_sch = self.class.find_or_initialize_by({
        lead_id:                  sch.lead_id,
        email_action_template_id: tie.next_tmpl.id,
      })
      next_sch.perform_at = eval(tie.next_at_exe)
      next_sch.status     = STATUS_ACTIVE
      next_sch.save!
    end
  end


  def self.list
    [[nil,nil]] + all.map { |p| [ "#{p.lead&.email} :: #{p.tmpl&.slug}", p.id ] }
  end
end

