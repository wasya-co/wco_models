
class WcoEmail::EmailFilterCondition
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'office_email_filter_conditions'

  belongs_to :email_filter,      class_name: '::WcoEmail::EmailFilter', inverse_of: :conditions,      optional: true
  belongs_to :email_skip_filter, class_name: '::WcoEmail::EmailFilter', inverse_of: :skip_conditions, optional: true

  ## see WcoEmail::FIELD_*
  field :field
  validates :field, presence: true

  field :operator, type: String
  validates :operator, presence: true, inclusion: WcoEmail::EmailFilter::OPERATOR_OPTS

  field :value
  validates :value, presence: true

  def apply leadset:, message:
    cond = self
    reason = nil
    case cond.field
    when WcoEmail::FIELD_LEADSET
      if cond.operator == WcoEmail::OPERATOR_NOT_HAS_TAG
        this_tag = Wco::Tag.find cond.value
        if leadset.tags.include?( this_tag )
          ;
        else
          reason = "#{email_skip_filter ? 'skip_' : ''}condition leadset not-has-tag #{this_tag} NOT met"
        end
      end
    when WcoEmail::FIELD_TO
      if message.to == cond.value
        reason = "{email_skip_filter ? 'skip_' : ''}condition to = #{cond.value}"
      end
    end
    return reason
  end


  def to_s
    "<EFC #{field} #{operator} #{value} />"
  end
  ## lets not do this. 2026-04-02
  # def to_s_full indent: 0
  #   _value = value
  #   if [ ::WcoEmail::OPERATOR_HAS_TAG, ::WcoEmail::OPERATOR_NOT_HAS_TAG ].include?( operator )
  #     _value = Wco::Tag.find( value )
  #   end
  #   "#{" " * indent }<EF#{email_skip_filter ? 'Skip' : ''}Condition #{field} #{operator} `#{_value}` />\n"
  # end

end

