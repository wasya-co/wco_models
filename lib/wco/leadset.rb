
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  field :domains, type: :string, default: 'orbital.city'

  has_many :serverhosts, class_name: 'Wco::Serverhost', inverse_of: :wco_leadset
  def next_serverhost
    serverhosts.first
  end

  has_many :appliances, class_name: 'Wco::Appliance', inverse_of: :wco_leadset

end
