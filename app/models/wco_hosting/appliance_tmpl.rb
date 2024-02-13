# require_relative '../wco/subscription'

class WcoHosting::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
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

  field :image
  validates :image, presence: true

  field :volume_zip
  validates :volume_zip, presence: true

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
  has_many :subscriptions, as: :product, class_name: 'Wco::Subscription'
  has_many :prices, as: :product, class_name: 'Wco::Price'

  # has_and_belongs_to_many :leadsets, class_name: 'Wco::Leadset'
  # has_many :appliance_tmpl_leadsets, class_name: 'WcoHosting::ApplianceTmplLeadset'

  field :product_id # stripe

  # belongs_to :price, class_name: 'Wco::Price', foreign_key: :wco_price_id

  field :price_id # stripe
  attr_accessor :tmp_price_cents
  attr_accessor :tmp_price_interval
  before_validation :set_stripe_product_price, on: :create
  def set_stripe_product_price
    stripe_product  = Stripe::Product.create({ name: "Appliance #{self}" })
    self.product_id = stripe_product.id

    wco_price   = Wco::Price.create!({
      amount_cents: tmp_price_cents,
      interval:     tmp_price_interval,
      product_id:   stripe_product.id,
      product:      self,
    })
    self.prices.push wco_price
    price_hash = {
      product:     stripe_product.id,
      unit_amount: tmp_price_cents,
      currency:    'usd',
      recurring: {
        interval: tmp_price_interval,
      },
    }
    stripe_price = Stripe::Price.create( price_hash )
    self.price_id = stripe_price.id
  end
  before_validation :update_stripe_product_price, on: :update
  def update_stripe_product_price
    if tmp_price_cents.present?
      price_hash = {
        product:     product_id,
        unit_amount: tmp_price_cents,
        currency:    'usd',
        recurring: {
          interval: tmp_price_interval,
        },
      }
      stripe_price  = Stripe::Price.create( price_hash )
      wco_price   = Wco::Price.create!({
        amount_cents: tmp_price_cents,
        interval:     tmp_price_interval,
        price_id:     stripe_price.id,
        product_id:   product_id,
        product:      self,
      })
      self.prices.push wco_price
    end
  end


  def to_s
    "#{kind}-#{version}"
  end
end
AppTmpl = WcoHosting::ApplianceTmpl