
class WcoEmail::EmailFilter
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_email_filters' ## 'wco_email_email_filters'

  field :slug, type: :string

  PAGE_PARAM_NAME = :filters_page

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  field :status, type: :string, default: STATUS_ACTIVE
  def self.active; where( :status.in => [ nil, STATUS_ACTIVE ] ); end

  has_many :actions, class_name: '::WcoEmail::EmailFilterAction', inverse_of: :email_filter
  accepts_nested_attributes_for :actions, allow_destroy: true, reject_if: :all_blank
  validate :validate_actions
  def validate_actions
    if actions.length == 0
      errors.add(:actions, 'must be present')
    end
  end

  has_many :conditions,      class_name: '::WcoEmail::EmailFilterCondition', inverse_of: :email_filter
  accepts_nested_attributes_for :conditions, allow_destroy: true, reject_if: :all_blank
  validate :validate_conditions
  def validate_conditions
    if conditions.length == 0
      errors.add(:condition, 'must be present')
    end
  end

  has_many :skip_conditions, class_name: '::WcoEmail::EmailFilterCondition', inverse_of: :email_skip_filter
  accepts_nested_attributes_for :skip_conditions, allow_destroy: true, reject_if: :all_blank

  has_and_belongs_to_many :leadsets,     class_name: '::Wco::Leadset'
  has_and_belongs_to_many :conversations, class_name: '::WcoEmail::Conversation'

  belongs_to :tag,                    class_name: '::Wco::Tag',                  optional: true, inverse_of: :email_filters

  def to_s
    "EmailFilter (#{conditions.length}) `#{slug}`"
  end
  def to_s_full
    attrs = ''
    if from_regex || from_exact
      attrs = "#{attrs} from=#{from_regex}#{from_exact}"
    end

    out =<<-AOL
<EmailFilter#{attrs} >
#{conditions.map { |c| c.to_s_full( indent: 2) }.join }
#{skip_conditions.map { |c| c.to_s_full( indent: 2) }.join }
#{actions.map { |c| c.to_s_full( indent: 2) }.join }
</EmailFilter>
AOL
    while out.match(/\n\n/) do
      out = out.gsub(/\n\n/, "\n")
    end
    out
  end


end
::EF = WcoEmail::EmailFilter

=begin

  ##
  ## deprecated
  ##

  ## @deprecated, use email_filter_conditions
  field :from_regex
  field :from_exact
  field :subject_regex
  field :subject_exact
  field :body_regex
  field :body_exact
  field :tag_id_exact

  field :skip_from_regex
  field :skip_to_exact

  ## @deprecated 2026-04-02, use email_filter_action::<KIND>
  # KIND_AUTORESPOND_TMPL = 'autorespond-template'
  # KIND_AUTORESPOND_EACT = 'autorespond-email-action'
  # KIND_REMOVE_TAG       = 'remove-tag'
  # KIND_ADD_TAG          = 'add-tag'
  # KIND_DESTROY_SCHS     = 'destroy-schs'
  # KIND_OAT              = 'office-action'
  # KIND_AUTORESPOND = 'autorespond' ## @deprecated, DO NOT USE!
  # KIND_DELETE      = 'delete'      ## @deprecated, use add-tag
  # KIND_SKIP_INBOX  = 'skip-inbox'  ## @deprecated, use remove-tag

  KINDS = [ nil, KIND_OAT, KIND_AUTORESPOND_TMPL, KIND_AUTORESPOND_EACT, KIND_ADD_TAG, KIND_REMOVE_TAG, KIND_DESTROY_SCHS ]
  field :kind ## @deprecated, use filter.action.aject.kind 2026-04-02

  ## @deprecated, use email_filter.email_action.aject
  belongs_to :email_template,         class_name: '::WcoEmail::EmailTemplate',        optional: true
  belongs_to :email_action_template,  class_name: '::WcoEmail::EmailActionTemplate',  optional: true
  belongs_to :office_action_template, class_name: '::Wco::OfficeActionTemplate', optional: true

  ## use to_s_full
  # def to_xml
  #   attrs = ''
  #   children = ''
  #   if from_regex || from_exact
  #     attrs = "#{attrs} from=#{from_regex}#{from_exact}"
  #   end
  #   if conditions.present?
  #     children = "#{children}#{conditions.map { |c| c.to_s }.join('') }"
  #   end
  #   return "<EF #{attrs}>#{children}</EF>\n"
  # end

=end



