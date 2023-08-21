
class Wco::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  validates :name, uniqueness: { scope: :leadset_id }, presence: true
  field :kind
  field :environment

  field :subdomain
  field :domain
  def host
    "#{subdomain}.#{domain}"
  end

  field :leadset_id
  def leadset
    Leadset.find leadset_id
  end

  belongs_to :serverhost, class_name: 'Wco::Serverhost'

end


