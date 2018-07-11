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

  field :email, :type => String

  field :number, :type => Integer
  increments :number

  field :amount, :type => Float

  has_many :payments, :class_name => 'Ish::Payment'
  field :paid_amount, :type => Float, :default => 0

  field :description, :type => String

end
