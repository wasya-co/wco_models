
class Wco::Leadset
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_leadsets'

  field :company_url
  def domain; company_url; end ## @TODO: remove
  validates :company_url, presence: true, uniqueness: true
  index({ company_url: 1 }, { name: 'company_url' })

  field :email
  index({ email: 1 }, { name: 'email' })
  validates :email, presence: true # , uniqueness: true ## @TODO: should it be unique? _vp_ 2023-12-22

  has_many :profiles,    class_name: 'Wco::Profile',           inverse_of: :leadset
  has_many :appliances,  class_name: 'WcoHosting::Appliance',  inverse_of: :leadset

  has_and_belongs_to_many :serverhosts, class_name: 'WcoHosting::Serverhost' # , inverse_of: :leadset
  def next_serverhost
    serverhosts.first
  end

end
