require 'autoinc'
# require "prawn"

##
## Invoice - for wasya.co
## 2017-10-31 _vp_ Start
## 2023-08-18 _vp_ Continue
##
class Ish::Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc

  store_in collection: 'ish_invoice'

  field :email, type: String

  field :invoice_id, type: String # stripe

  field :leadset_id, type: Integer
  def leadset
    Leadset.find leadset_id
  end

  field :number, type: Integer
  increments :number

  field :amount_cents, type: Integer

  has_many :payments, :class_name => 'Ish::Payment'
  field :paid_amount_cents, type: Integer, :default => 0 ## @TODO: unused? _vp_ 2023-08-18

  field :description, type: String

  field :items, type: Array

  # def generate_pdf pdf=nil
  #   pdf ||= Prawn::Document.new
  #   pdf.text "Job Summary."
  #   filename = "a-summary.pdf"
  #   path = Rails.root.join 'tmp', filename
  #   pdf.render_file path
  #   data = File.read path
  #   File.delete(path) if File.exist?(path)
  #   return data
  # end

end
