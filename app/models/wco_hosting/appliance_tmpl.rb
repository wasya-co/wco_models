# require_relative '../wco/subscription'

class WcoHosting::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_appliance_tmpls'

  ## 2023-12-08 :: These names are impossible to change already.
  KIND_CRM        = 'crm'        # trash
  KIND_DRUPAL     = 'drupal'     # drupal
  KIND_HELLOWORLD = 'helloworld' # static
  KIND_IROWOR     = 'irowor'     # ror
  KIND_JENKINS    = 'jenkins'    # jenkins
  KIND_MATOMO     = 'matomo'     # docker
  KIND_MOODLE     = 'moodle'     # docker
  KIND_PRESTASHOP = 'prestashop' # docker
  KIND_REACT      = 'react'      # static
  KIND_SMT        = 'smt'        # ror
  KIND_WORDPRESS  = 'wordpress'  # docker
  KIND_TRASH      = 'trash'      # trash
  KIND_TMP        = 'tmp'        # static

  KINDS = [ nil, KIND_CRM, KIND_DRUPAL, KIND_HELLOWORLD, KIND_IROWOR,
    KIND_JENKINS, KIND_MATOMO, KIND_MOODLE, KIND_PRESTASHOP,
    KIND_REACT,
    KIND_SMT,
    KIND_WORDPRESS, KIND_TRASH, KIND_TMP ]

  field :kind, type: :string
  validates :kind, uniqueness: { scope: :version }, presence: true

  field :version, type: :string, default: '0.0.0'
  validates :version, uniqueness: { scope: :kind }, presence: true
  index({ kind: -1, version: -1 }, { name: 'kind_version' })

  def name
    "#{kind} #{version}"
  end

  def playbook_name
    case kind
    when KIND_SMT
      return 'hosted-packagedapp'
    when KIND_DRUPAL
      return 'hosted-drupal'
    when KIND_HELLOWORLD
      return 'hosted-static'
    else
      throw '0ip - not implemented'
    end
  end

  field :descr, type: :string

  field :ecs_task_definition_erb, type: :string
  # def ecs_task_definition
  #   ac   = ActionController::Base.new
  #   ac.instance_variable_set( :@tmpl, self )
  #   rendered_str = ac.render_to_string("wco_hosting/scripts/nginx_site.conf")
  #   Wco::Log.puts! rendered_str, 'add_nginx_site rendered_str', obj: @obj
  #   file = Tempfile.new('prefix')
  #   file.write rendered_str
  #   file.close
  # end

  field :docker_compose_erb, type: :string

  field :stdout, type: :string, default: ''
  field :stderr, type: :string, default: ''

  field :image
  # validates :image, presence: true

  field :volume_zip_url
  field :volume_zip_rb
  def volume_zip
    if volume_zip_rb
      eval( volume_zip_rb )
    else
      volume_zip_url
    end
  end

  field :db_zip_url




  def self.latest_of kind
    where({ kind: kind }).order_by({ version: :desc }).first
  end

  has_many :appliances, class_name: 'WcoHosting::Appliance'
  has_many :leadsets,   class_name: 'Wco::LeadsetApplianceTmpl', inverse_of: :appliance_tmpl
  has_many :subscriptions, as: :product, class_name: 'Wco::Subscription'
  has_many :prices,        as: :product, class_name: 'Wco::Price'
  has_and_belongs_to_many :task_tmpls, class_name: 'WcoHosting::TaskTmpl'

  field :product_id # stripe

  # belongs_to :price, class_name: 'Wco::Price', foreign_key: :wco_price_id

  field :price_id # stripe

  before_validation :set_stripe_product_price, on: :create
  def set_stripe_product_price
    stripe_product  = Stripe::Product.create({ name: "Appliance #{self}" })
    self.product_id = stripe_product.id
  end

  def to_s
    "#{kind}-#{version}"
  end
  def self.list
    all.map { |apl| [apl.to_s, apl.id.to_s] }
  end
end
AppTmpl = WcoHosting::ApplianceTmpl