
class Ish::Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :invoice, class_name: 'Ish::Invoice', optional: true
  belongs_to :profile, class_name: 'Ish::UserProfile'
  belongs_to :item,    polymorphic: true

  field :amount, :type => Integer # in cents
  field :charge, :type => Hash
  field :email,  :type => String

  field :client_secret
  field :payment_intent_id

  STATUS_CONFIRMED = 'confirmed'
  STATUS_PENDING = 'pending'
  STATUSES = %w| active pending |
  field :status, type: Symbol, default: STATUS_PENDING
  scope :confirmed, ->{ where( status: STATUS_CONFIRMED ) }

  after_create :compute_paid_invoice_amount
  def compute_paid_invoice_amount
    self.invoice&.update_attributes({ paid_amount: self.invoice.paid_amount + self.amount })
  end

end

