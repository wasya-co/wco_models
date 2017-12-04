
#
# Lead
# _vp_ 20171204
#
class Ish::Lead
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_lead'

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

  field :email
  field :job_url
  field :company, :default => ''
  field :description

=begin
  field :amount, :type => Float
  has_many :payments, :class_name => 'Ish::Payment'
  field :description, :type => String
=end

end
