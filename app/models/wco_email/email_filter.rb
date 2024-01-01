
##
## 2023-03-04 _vp_ When I receive one.
##
class WcoEmail::EmailFilter
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_email_filters'

  field :from_regex
  field :from_exact
  field :subject_regex
  field :subject_exact
  field :body_regex
  field :body_exact


  KIND_AUTORESPOND_TMPL = 'autorespond-template'
  KIND_AUTORESPOND_EACT = 'autorespond-email-action'
  KIND_REMOVE_TAG       = 'remove-tag'
  KIND_ADD_TAG          = 'add-tag'
  KIND_DESTROY_SCHS     = 'destroy-schs'

  KIND_AUTORESPOND = 'autorespond' # @deprecated, DO NOT USE!
  KIND_DELETE      = 'delete'      # @deprecated, use add-tag
  KIND_SKIP_INBOX  = 'skip-inbox'  # @deprecated, use remove-tag

  KINDS = [ nil, KIND_AUTORESPOND_TMPL, KIND_AUTORESPOND_EACT, KIND_ADD_TAG, KIND_REMOVE_TAG, KIND_DESTROY_SCHS]
  field :kind

  STATE_ACTIVE   = 'active'
  STATE_INACTIVE = 'inactive'
  STATES = [ STATE_ACTIVE, STATE_INACTIVE ]
  field :state, type: :string, default: STATE_ACTIVE
  scope :active, ->{ where( state: STATE_ACTIVE ) }

  belongs_to :email_template, class_name: 'WcoEmail::EmailTemplate', optional: true
  belongs_to :email_action,   class_name: 'WcoEmail::EmailAction',   optional: true

  field :wp_term_id, type: :integer
  def category
    self.wp_term_id && WpTag.find( self.wp_term_id )
  end

end

