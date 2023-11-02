
class Wco::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  validates :name, uniqueness: { scope: :leadset_id }, presence: true

  field :kind

  field :service_name
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

  belongs_to :appliance_tmpl, class_name: 'Wco::ApplianceTmpl'
  def tmpl
    appliance_tmpl
  end

  belongs_to :serverhost,     class_name: 'Wco::Serverhost'
  # field :ip
  field :port

end


