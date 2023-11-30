
##
## 2023-11-30 _vp_ For use in hosting!
## 2023-11-30 _vp_ For future use in email!
##
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  field :company_url
  validates :company_url, presence: true, uniqueness: true

  has_many :wco_leads, class_name: 'Ish::UserProfile'

  # field :domains, type: :string, default: 'orbital.city'

  has_many :serverhosts, class_name: 'Wco::Serverhost', inverse_of: :wco_leadset
  def next_serverhost
    serverhosts.first
  end

  has_many :appliances, class_name: 'Wco::Appliance', inverse_of: :wco_leadset

end
