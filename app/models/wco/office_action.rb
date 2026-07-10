
class Wco::OfficeAction
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_office_actions'

  field     :slug, type: :string
  validates :slug, uniqueness: true, allow_nil: true

  # field :descr, type: :string ## optional

  belongs_to :office_action_template, inverse_of: :office_action
  belongs_to :lead, class_name: '::Wco::Lead'

  def tmpl
    office_action_template
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ STATUS_ACTIVE, STATUS_INACTIVE ]
  field :status, type: :string
  scope :active, ->{ where( status: STATUS_ACTIVE ) }
  attr_accessor :deactivate

  field :perform_at, type: :time
  field :config, type: Hash, default: {}

  def do_run
    @oa = self
    @oa.update!({ status: STATUS_INACTIVE })
    @oat = @oa.office_action_template

    begin
      eval( @oa.tmpl.action_exe )
    rescue => err
      puts! err, "Wco::OfficeAction#do_run"
      ::ExceptionNotifier.notify_exception( err, data: { office_action: self } )
    end

    if @oa.deactivate
      ; # nothing
    else
      # schedule next actions & update the action
      @oa.tmpl.ties.each do |tie|
        next_oa = self.class.find_or_initialize_by({
          office_action_template_id: tie.next_tmpl.id,
        })
        next_oa.perform_at = eval(tie.next_at_exe)
        next_oa.status     = STATUS_ACTIVE
        next_oa.save!
      end
    end
  end

  def to_s
    slug
  end
end
OA ||= Wco::OfficeAction
