
class WcoEmail::EmailFilterAction
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'email_filter_actions'

  belongs_to :email_filter

  ## deprecated, use obj
  KIND_EXE         = 'exe'
  KIND_REMOVE_TAG  = ::WcoEmail::ACTION_REMOVE_TAG
  KIND_ADD_TAG     = ::WcoEmail::ACTION_ADD_TAG
  KIND_AUTORESPOND = ::WcoEmail::ACTION_AUTORESPOND
  KIND_SCHEDULE_EMAIL_ACTION = 'autorespond-email-action'
  KIND_REMOVE_EMAIL_ACTION   = 'remove-email-action'
  field :kind
  validates :kind, inclusion: ::WcoEmail::ACTIONS

  ## deprecated, use abject
  field :value # tag_id , or email_template , or email_action_template (not used)

  belongs_to :abject, polymorphic: true, optional: true # eg tag, EAT, OAT

  before_validation :check_value
  def check_value
    case kind
    when KIND_AUTORESPOND
      existing = WcoEmail::EmailTemplate.where({ id: value }).first
      if !existing
        errors.add( :base, 'missing EmailTemplate id when creating an EmailFilterAction' )
        throw :abort
      end
    end
  end


  def to_s
    "<EFA #{kind} #{value} />\n"
  end
  # def to_s_full indent: 0
  #   _value = value
  #   if [ KIND_ADD_TAG, KIND_REMOVE_TAG ].include?( kind )
  #     _value = Wco::Tag.find( value )
  #   end
  #   if [ KIND_AUTORESPOND ].include?( kind )
  #     _value = WcoEmail::EmailTemplate.find( value )
  #   end
  #   "#{" " * indent }<EFAction #{kind} `#{_value}` />\n"
  # end

end
