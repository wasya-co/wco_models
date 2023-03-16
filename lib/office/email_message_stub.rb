
##
## Only object_key, object_path, no validations.
##
class Office::EmailMessageStub
  include Mongoid::Document
  include Mongoid::Timestamps

  STATE_PENDING   = 'state_pending'
  STATE_PROCESSED = 'state_processed'
  STATES          = [ STATE_PENDING, STATE_PROCESSED ]
  field :state, type: :string, default: STATE_PENDING

  field :object_key,  type: :string ## aka 'filename', use with bucket name + prefix
  validates_presence_of :object_key

  field :object_path, type: :string ## A routable s3 url ## @TODO: remove this field. _vp_ 2023-03-07
  # validates_presence_of :object_path ## only need object_key == message_id

  field :wp_term_ids, type: :array, default: []

end
Stub = EMS = Office::EmailMessageStub
