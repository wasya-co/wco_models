require 'autoinc'

#
# Invoice - for wasya.co
# _vp_ 20171031
#
class Ish::Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc

  store_in :collection => 'ish_invoice'

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

  field :number, :type => Integer
  increments :number

  field :amount, :type => Float

  has_many :payments, :class_name => 'Ish::Payment'

  field :description, :type => String

end
