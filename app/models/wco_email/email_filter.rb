
class WcoEmail::EmailFilter
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_email_filters' ## 'wco_email_email_filters'

  PAGE_PARAM_NAME = :filters_page

  FIELD_OPTS     = [ 'subject', 'from', 'to', 'to-or-cc', 'body', ] ## 'lead_tag_id'

  OPERATOR_OPTS = [ 'regex', 'eq', 'match-i' ]


  field :from_regex
  field :from_exact
  field :subject_regex
  field :subject_exact
  field :body_regex
  field :body_exact
  field :tag_id_exact

  field :skip_from_regex
  field :skip_to_exact

  has_many :actions, class_name: '::WcoEmail::EmailFilterAction', inverse_of: :email_filter
  accepts_nested_attributes_for :actions, allow_destroy: true
  # validate :validate_actions
  def validate_actions
    if actions.length == 0
      errors.add(:actions, 'must be present')
    end
  end

  ## 'and' - all conditions must match, for filter to match
  has_many :conditions,      class_name: '::WcoEmail::EmailFilterCondition', inverse_of: :email_filter
  accepts_nested_attributes_for :conditions, allow_destroy: true

  ## 'and' - all conditions must match, for filter to match
  has_many :skip_conditions, class_name: '::WcoEmail::EmailFilterCondition', inverse_of: :email_skip_filter
  accepts_nested_attributes_for :skip_conditions, allow_destroy: true

  # validate :validate_conditions
  def validate_conditions
    if conditions.length + skip_conditions.length == 0
      errors.add(:conditions, 'Either conditions or skip conditions must be present.')
    end
  end

  has_and_belongs_to_many :leadsets,     class_name: '::Wco::Leadset'


  KIND_AUTORESPOND_TMPL = 'autorespond-template'
  KIND_AUTORESPOND_EACT = 'autorespond-email-action'
  KIND_REMOVE_TAG       = 'remove-tag'
  KIND_ADD_TAG          = 'add-tag'
  KIND_DESTROY_SCHS     = 'destroy-schs'
  KIND_OAT              = 'office-action'

  ## @deprecated
  KIND_AUTORESPOND = 'autorespond' ## @deprecated, DO NOT USE!
  KIND_DELETE      = 'delete'      ## @deprecated, use add-tag
  KIND_SKIP_INBOX  = 'skip-inbox'  ## @deprecated, use remove-tag

  KINDS = [ nil, KIND_OAT, KIND_AUTORESPOND_TMPL, KIND_AUTORESPOND_EACT, KIND_ADD_TAG, KIND_REMOVE_TAG, KIND_DESTROY_SCHS]
  field :kind


  belongs_to :email_template,         class_name: '::WcoEmail::EmailTemplate',        optional: true
  belongs_to :email_action_template,  class_name: '::WcoEmail::EmailActionTemplate',  optional: true

  ## no habtm please
  # has_and_belongs_to_many :action_tmpls, class_name: '::Wco::OfficeActionTemplate'
  belongs_to :office_action_template, class_name: '::Wco::OfficeActionTemplate', optional: true
  belongs_to :tag,                    class_name: '::Wco::Tag',                  optional: true, inverse_of: :email_filters

  ## @TODO: change to has_and_belongs_to_many, test-driven.
  has_many :conversations, class_name: '::WcoEmail::Conversation', inverse_of: :filter

  def to_s
    "EmailFilter: #{from_regex} #{from_exact} #{conditions.map { |c| c.to_s }.join }"
  end
  def to_s_full
    # inn = ""
    # inn = "#{inn}#{conditions.map { |c| c.to_s_full }.join }" if conditions.present?
    # inn = "#{inn}#{skip_conditions.map { |c| c.to_s_full }.join }" if skip_conditions.present?
    out =<<-AOL
<EmailFilter #{from_regex} #{from_exact}>
#{conditions.map { |c| c.to_s_full( indent: 2) }.join }
#{skip_conditions.map { |c| c.to_s_full( indent: 2) }.join }
#{actions.map { |c| c.to_s_full( indent: 2) }.join }
</EmailFilter>"
AOL
    while out.match(/\n\n/) do
      out = out.gsub(/\n\n/, "\n")
    end
    out
  end

  def to_xml
    attrs = ''
    children = ''
    if from_regex || from_exact
      attrs = "#{attrs} from=#{from_regex}#{from_exact}"
    end
    if conditions.present?
      children = "#{children}#{conditions.map { |c| c.to_s }.join('') }"
    end
    return "<EF #{attrs}>#{children}</EF>\n"
  end



end
::EF = WcoEmail::EmailFilter
