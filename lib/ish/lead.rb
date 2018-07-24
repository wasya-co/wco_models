
#
# Lead
# _vp_ 20171204
#
class Ish::Lead
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_lead'

  belongs_to :profile, :class_name => 'IshModels::UserProfile'

  has_and_belongs_to_many :campaigns,             :class_name => 'Ish::Campaign', :inverse_of => :leads
  has_and_belongs_to_many :unsubscribe_campaigns, :class_name => 'Ish::Campaign', :inverse_of => :unsubscribe_leads

  field :email
  field :job_url
  field :company_url
  field :website_html
  field :yelp_url

  field :company
  validates_uniqueness_of :company
  index({ :company => -1 })

  field :description

  STATES = %w( considering applied )
  field :state, :type => String

  field :is_done,  :type => Boolean, :default => false
  field :is_trash, :type => Boolean, :default => false

  field :applied_on, :type => Time

  field :tag, :type => String # 'hired_com_ror', not enumerated for now _vp_ 20180103
  field :location

  field :raw_phone, :type => String
  def phone= which
    write_attribute :raw_phone, which
    write_attribute :phone, which.gsub(/\D/, '').to_i
  end
  field :phone, :type => Integer
  field :address, :type => String

  # If I crawl on 20180724, I add "20180724" here, so I don't crawl in the same way again.
  field :extra, :type => Array, :default => []

end
