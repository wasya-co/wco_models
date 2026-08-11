
class WcoEmail::EmailFilterCondition
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_email_filter_conditions'

  belongs_to :email_filter,      class_name: '::WcoEmail::EmailFilter', inverse_of: :conditions,      optional: true
  belongs_to :email_skip_filter, class_name: '::WcoEmail::EmailFilter', inverse_of: :skip_conditions, optional: true
  index({ email_filter_id: 1, email_skip_filter_id: 1, field: 1, operator: 1, value: 1 }, unique: true )

  FIELD_BODY        = 'body'
  FIELD_BODY_PLAIN  = 'body-plain'
  FIELD_FROM        = 'from'
  FIELD_LEADSET     = 'from-leadset'
  FIELD_SUBJECT     = 'subject'
  FIELD_TAGGED      = 'leadset-tagged'     ## either lead or leadset, actually
  FIELD_NOT_TAGGED  = 'leadset-not-tagged' ## either lead or leadset, actually
  FIELD_TO_OR_CC    = 'to-or-cc'
  FIELD_OPTS = [
    FIELD_BODY, FIELD_BODY_PLAIN,
    FIELD_FROM,
    FIELD_LEADSET,
    FIELD_SUBJECT,
    FIELD_TAGGED,
    FIELD_NOT_TAGGED,
    FIELD_TO_OR_CC,
  ];
  field :field
  validates :field, presence: true, inclusion: FIELD_OPTS

  OPERATOR_EQUALS      = 'eq-i'
  OPERATOR_HAS_TAG     = 'has-tag'
  OPERATOR_NOT_HAS_TAG = 'not-has-tag'
  OPERATOR_REGEX = 'regex'
  OPERATOR_MATCH = 'match-i'
  OPERATOR__ID   = '_id'
  OPERATOR_SLUG  = 'slug'
  OPERATOR_OPTS = [ OPERATOR__ID,
    OPERATOR_EQUALS,
    OPERATOR_HAS_TAG,
    OPERATOR_MATCH,
    OPERATOR_NOT_HAS_TAG,
    OPERATOR_REGEX,
    OPERATOR_SLUG, ]
  field :operator
  validates :operator, presence: true, inclusion: OPERATOR_OPTS

  field :value
  validates :value, presence: true
  before_validation :strip_value
  def strip_value
    self.value = value.strip
  end

  field :comment


  def apply lead:, message:
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

    when WcoEmail::EmailFilterCondition::FIELD_LEADSET
      if cond.operator == WcoEmail::EmailFilterCondition::OPERATOR__ID
        test_leadset = Wco::Leadset.find( value ) rescue nil
        if test_leadset
          if lead.leadset == test_leadset
            reason = "#{email_skip_filter ? 'skip_' : ''}condition leadset _id `#{value}`"
          end
        end
      end

    when WcoEmail::EmailFilterCondition::FIELD_TAGGED
      ## cond.operator should eql OPERATOR__ID but I don't check b/c if its slug, it should work also.
      tag   = Wco::Tag.find( cond.value ) rescue nil
      tag ||= Wco::Tag.where( slug: cond.value ).first
      if tag
        if lead.leadset.tags.include?( tag ) ||
           lead.tags.include?( tag )

          reason = "#{email_skip_filter ? 'skip_' : ''}condition TAGGED `#{tag.slug}`"

        end
      end

    when WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED
      ## cond.operator should eql OPERATOR__ID but I don't check b/c if its slug, it should work also.
      tag   = Wco::Tag.find( cond.value ) rescue nil
      tag ||= Wco::Tag.where( slug: cond.value ).first
      if tag
        if !lead.leadset.tags.include?( tag ) &&
           !lead.tags.include?( tag )

          reason = "#{email_skip_filter ? 'skip_' : ''}condition NOT_TAGGED `#{tag.slug}`"

        end
      end

    end ## end case

    return reason
  end


  def to_s
    "<EF#{email_skip_filter ? 'Skip' : ''}Condition #{field} #{operator} `#{value}` />"
  end
  def to_s_full indent: 0
    "#{" " * indent }<EF#{email_skip_filter ? 'Skip' : ''}Condition #{field} #{operator} `#{value}` #{comment} />\n"
  end


end
::EFC = ::WcoEmail::EmailFilterCondition
