class Ish::Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :invoice, :class_name => 'Ish::Invoice', optional: true
  belongs_to :profile, :class_name => 'Ish::UserProfile' # , :optional => true

  field :amount, :type => Integer # in cents
  field :charge, :type => Hash
  field :email,  :type => String

  field :client_secret
  field :payment_intent_id

  field :status, type: Symbol

  after_create :compute_paid_invoice_amount

  protected

  def compute_paid_invoice_amount
    if self.invoice
      self.invoice.update_attributes :paid_amount => self.invoice.paid_amount + self.amount
    end
  end

end

