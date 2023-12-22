
class WcoHosting::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_appliance_tmpls'

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

  ## Only underscores! These become variable names.
  # KIND_CRM        = 'kind_crm'
  # KIND_DRUPAL     = 'kind_drupal'
  # KIND_HELLOWORLD = 'kind_helloworld'
  # KIND_IROWOR     = 'kind_irowor'
  # KIND_JENKINS    = 'kind_jenkins'
  # KIND_MATOMO     = 'kind_matomo'
  # KIND_MOODLE     = 'kind_moodle'
  # KIND_PRESTASHOP = 'kind_prestashop'
  # KIND_SMT        = 'kind_smt'
  # KIND_WORDPRESS  = 'kind_wordpress'

  ## 2023-12-08 :: These names are impossible to change already.
  KIND_CRM        = 'crm'
  KIND_DRUPAL     = 'drupal'
  KIND_HELLOWORLD = 'helloworld'
  KIND_IROWOR     = 'irowor'
  KIND_JENKINS    = 'jenkins'
  KIND_MATOMO     = 'matomo'
  KIND_MOODLE     = 'moodle'
  KIND_PRESTASHOP = 'prestashop'
  KIND_SMT        = 'smt'
  KIND_WORDPRESS  = 'wordpress'

  KINDS = [ KIND_CRM, KIND_DRUPAL, KIND_HELLOWORLD, KIND_IROWOR,
    KIND_JENKINS, KIND_MATOMO, KIND_MOODLE, KIND_PRESTASHOP, KIND_SMT,
    KIND_WORDPRESS ]

  has_many :appliances, class_name: 'WcoHosting::Appliance'

  def self.latest_of kind
    where({ kind: kind }).order_by({ version: :desc }).first
  end

end
AppTmpl = WcoHosting::ApplianceTmpl