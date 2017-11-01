
class Ish::Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :invoice, :class_name => 'Ish::Invoice'
  belongs_to :profile, :class_name => 'IshModels::UserProfile', :optional => true

  field :amount, :type => Float
  field :charge, :type => Hash

end

  
