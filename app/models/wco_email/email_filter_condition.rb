
class WcoEmail::EmailFilterCondition
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_email_filter_conditions'

  belongs_to :email_filter,      class_name: '::WcoEmail::EmailFilter', inverse_of: :conditions,      optional: true
  belongs_to :email_skip_filter, class_name: '::WcoEmail::EmailFilter', inverse_of: :skip_conditions, optional: true

  FIELD_BODY    = 'body'
  FIELD_BODY_PLAIN = 'body-plain'
  FIELD_FROM    = 'from'
  FIELD_TAGGED  = 'leadset-tagged'
  FIELD_NOT_TAGGED  = 'leadset-not-tagged'
  FIELD_SUBJECT  = 'subject'
  # FIELD_TO       = 'to'
  FIELD_TO_OR_CC = 'to-or-cc'
  FIELD_OPTS     = [ FIELD_SUBJECT, FIELD_FROM, FIELD_TO_OR_CC, FIELD_TAGGED, FIELD_NOT_TAGGED, FIELD_BODY, FIELD_BODY_PLAIN ]
  field :field
  validates :field, presence: true, inclusion: FIELD_OPTS

  OPERATOR_EQUALS      = 'eq-i'
  # OPERATOR_HAS_TAG     = 'has-tag'
  # OPERATOR_NOT_HAS_TAG = 'not-has-tag'
  OPERATOR_REGEX = 'regex'
  OPERATOR_MATCH = 'match-i'
  OPERATOR__ID = '_id'
  OPERATOR_SLUG = 'slug'
  OPERATOR_OPTS = [ OPERATOR_REGEX, OPERATOR_MATCH, OPERATOR__ID, OPERATOR_SLUG ]
  field :operator
  validates :operator, presence: true, inclusion: OPERATOR_OPTS

  field :value
  validates :value, presence: true

  index({ email_filter_id: 1, field: 1, operator: 1, value: 1 }, unique: true )

  def apply leadset:, message:
    cond = self
    reason = nil
    case cond.field
    ## from match-i <value>
    when WcoEmail::EmailFilterCondition::FIELD_FROM
      if cond.operator == WcoEmail::EmailFilterCondition::OPERATOR_MATCH
        if message.from.downcase.include?( value.downcase )
          reason = "#{email_skip_filter ? 'skip_' : ''}condition from match-i `#{value}`"
        end
      end
    end
    # when WcoEmail::FIELD_LEADSET
    #   if cond.operator == WcoEmail::OPERATOR_NOT_HAS_TAG
    #     this_tag = Wco::Tag.find cond.value
    #     if leadset.tags.include?( this_tag )
    #       ;
    #     else
    #       reason = "#{email_skip_filter ? 'skip_' : ''}condition leadset not-has-tag #{this_tag} NOT met"
    #     end
    #   end
    # when WcoEmail::FIELD_TO
    #   if message.to == cond.value
    #     reason = "{email_skip_filter ? 'skip_' : ''}condition to = #{cond.value}"
    #   end
    # end
    return reason
  end


  def to_s
    "<EF#{email_skip_filter ? 'Skip' : ''}Condition #{field} #{operator} `#{value}` />"
  end
  def to_s_full indent: 0
    "#{" " * indent }<EF#{email_skip_filter ? 'Skip' : ''}Condition #{field} #{operator} `#{value}` />\n"
  end

end

