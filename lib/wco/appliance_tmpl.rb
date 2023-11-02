
class Wco::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kind
  validates :kind, uniqueness: true, presence: true

  field :image
  validates :image, presence: true

  field :volume_zip
  validates :volume_zip, presence: true

  KIND_CORPHOME1  = 'corphome1'
  KIND_DRUPAL     = 'drupal'
  KIND_HELLOWORLD = 'helloworld'
  KINDS = [ 'smt', 'emailcrm', KIND_CORPHOME1, KIND_HELLOWORLD, KIND_DRUPAL,
    'mautic', 'matomo',
    'irowor', 'eCommerce' ]

  has_many :appliances, class_name: 'Wco::Appliance'
end
