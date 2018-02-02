
#
# Campaign
# _vp_ 20180128
#
class Ish::Campaign
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_campaign'

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

  has_and_belongs_to_many :leads,             :class_name => 'Ish::Lead'
  has_and_belongs_to_many :unsubscribe_leads, :class_name => 'Ish::Lead'

  field :subject
  field :body

  

  field :is_done,  :type => Boolean, :default => false
  field :is_trash, :type => Boolean, :default => false

  field :applied_on, :type => Time

  field :tag # 'hired_com_ror', not enumerated for now _vp_ 20180103
  field :location

end
