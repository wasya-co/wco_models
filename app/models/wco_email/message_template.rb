
class WcoEmail::MessageTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_message_template'

end
