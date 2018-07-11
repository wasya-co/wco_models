class Ish::Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :invoice, :class_name => 'Ish::Invoice'
  # belongs_to :profile, :class_name => 'IshModels::UserProfile', :optional => true

  field :amount, :type => Float
  field :charge, :type => Hash
  field :email,  :type => String
  
  after_create :compute_paid_invoice_amount

  protected

  def compute_paid_invoice_amount
    self.invoice.update_attributes :paid_amount => self.invoice.paid_amount + self.amount
  end

end

