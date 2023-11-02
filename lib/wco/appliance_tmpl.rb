
class Wco::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kind
  validates :kind, uniqueness: { scope: :version }, presence: true

  field :version, type: :string, default: '0.0.0'
  validates :version, uniqueness: { scope: :kind }, presence: true
  index({ kind: -1, version: -1 }, { name: :kind_version })

  field :descr, type: :string

  field :image
  validates :image, presence: true

  field :volume_zip
  validates :volume_zip, presence: true

  KIND_CORPHOME1  = 'corphome1'
  KIND_DRUPAL     = 'drupal'
  KIND_HELLOWORLD = 'helloworld'
  # KINDS = [ 'smt', 'emailcrm', KIND_CORPHOME1, KIND_HELLOWORLD, KIND_DRUPAL,
  #   'mautic', 'matomo',
  #   'irowor', 'eCommerce' ]
  KINDS = [ KIND_HELLOWORLD ]

  has_many :appliances, class_name: 'Wco::Appliance'

  def self.latest_of kind
    where({ kind: kind }).order_by({ version: :desc }).first
  end

end
AppTmpl = Wco::ApplianceTmpl
