
class WcoEmail::EmailFilterAction
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'email_filter_actions'

  belongs_to :email_filter

  KIND_AUTORESPOND = 'autorespond-template'
  # KIND_EXE_RB      = 'exe-rb'
  KIND_ADD_TAG     = 'add-tag'
  KIND_RM_TAG      = 'remove-tag'
  KIND_EAT         = 'autorespond-email-action'
  KIND_RM_EAT      = 'rm-email-action'
  KIND_OAT         = 'office-action-template'
  KIND_RM_OAT      = 'rm-office-action-template'
  KINDS = [ KIND_ADD_TAG, KIND_RM_TAG, KIND_AUTORESPOND, KIND_OAT, KIND_EAT, KIND_RM_EAT ]
  field :kind
  validates :kind, inclusion: KINDS

  ## for exe_rb only. otherwise, use aject
  field :value

  belongs_to :aject, polymorphic: true # , optional: true # eg tag, EAT, OAT
  # validates :aject_id, presence: true

  ## 2026-04-02 not anymore.
  # before_validation :check_value
  # def check_value
  #   case kind
  #   when KIND_AUTORESPOND
  #     existing = WcoEmail::EmailTemplate.where({ id: value }).first
  #     if !existing
  #       errors.add( :base, 'missing EmailTemplate id when creating an EmailFilterAction' )
  #       throw :abort
  #     end
  #   end
  # end


  def to_s
    "<EFAction #{kind} #{aject} />\n"
  end
  def to_s_full indent: 0
    "#{" " * indent }<EFAction #{kind} `#{aject}` />\n"
  end

end
EFA = WcoEmail::EmailFilterAction
