# require_relative '../wco/subscription'

class WcoHosting::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_appliance_tmpls'

  field :kind, type: :string
  validates :kind, uniqueness: { scope: :version }, presence: true

  field :version, type: :string, default: '0.0.0'
  validates :version, uniqueness: { scope: :kind }, presence: true
  index({ kind: -1, version: -1 }, { name: 'kind_version' })

  def name
    "#{kind} #{version}"
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
  field :volume_zip_exe
  def volume_zip
    if volume_zip_exe
      eval( volume_zip_exe )
    else
      volume_zip_url
    end
  end

  ## 2023-12-08 :: These names are impossible to change already.
  KIND_CRM        = 'crm'
  KIND_DRUPAL     = 'drupal'
  KIND_HELLOWORLD = 'helloworld'
  KIND_IROWOR     = 'irowor'
  KIND_JENKINS    = 'jenkins'
  KIND_MATOMO     = 'matomo'
  KIND_MOODLE     = 'moodle'
  KIND_PRESTASHOP = 'prestashop'
  KIND_REACT      = 'react'
  KIND_SMT        = 'smt'
  KIND_WORDPRESS  = 'wordpress'
  KIND_TRASH      = 'trash'
  KIND_TMP        = 'tmp'

  KINDS = [ nil, KIND_CRM, KIND_DRUPAL, KIND_HELLOWORLD, KIND_IROWOR,
    KIND_JENKINS, KIND_MATOMO, KIND_MOODLE, KIND_PRESTASHOP,
    KIND_REACT,
    KIND_SMT,
    KIND_WORDPRESS, KIND_TRASH, KIND_TMP ]



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
end
AppTmpl = WcoHosting::ApplianceTmpl