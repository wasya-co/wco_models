require 'autoinc'
require 'prawn'
require 'prawn/table'

##
## Invoice - for wasya.co
## 2017-10-31 _vp_ Start
## 2023-08-18 _vp_ Continue
##
class Wco::Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Autoinc
  include Mongoid::Paranoia
  store_in collection: 'ish_invoice'

  field :email, type: String

  field :invoice_id, type: String # stripe

  belongs_to :leadset, class_name: 'Wco::Leadset'

  field :number, type: Integer

  field :month_on, type: Date

  has_one :asset, class_name: 'Wco::Asset' ## the pdf

  def filename
    "invoice-#{number}.pdf"
  end

  # field :amount_cents, type: Integer

  field :description, type: String
  field :items,       type: Array   # used by stripe



  ## Prawn/pdf unit of measure is 1/72"
  ## Canvas width: 612, height: 792
  ##
  ## tree image: 896 x 1159
  ## tree image: 791 x 1024
  ## tree image: 964 x 1248
  ##
  def generate_monthly_invoice
    tree_img_url      = "#{Rails.root.join('public')}/tree-#{number}.jpg"
    wasya_co_logo_url = "#{Rails.root.join('public')}/259x66-WasyaCo-logo.png"

    ## canvas width: 612, height: 792
    pdf = Prawn::Document.new

    pdf.canvas do
      pdf.image tree_img_url, at: [ 0, 792 ], width: 612

      pdf.fill_color 'ffffff'
      pdf.transparent( 0.75 ) do
        pdf.fill_rectangle [0, 792], 612, 792
      end
      pdf.fill_color '000000'

      pdf.image wasya_co_logo_url, at: [252, 720], width: 108 ## 1.5"

      pdf.bounding_box( [0.75*72, 9.25*72], width: 3.25*72, height: 0.75*72 ) do
        pdf.text "From:"
        pdf.text "Wasya Co"
        pdf.text "victor@wasya.co"
      end

      pdf.bounding_box( [4.5*72, 9.25*72], width: 3.25*72, height: 0.75*72 ) do
        pdf.text "Stats:"
        pdf.text "Date: #{ Time.now.to_date.to_s }"
        pdf.text "Invoice #: #{ number }"
      end

      pdf.bounding_box( [0.75*72, 8.25*72], width: 3.25*72, height: 0.75*72 ) do
        pdf.text "To:"
        pdf.text leadset.name
        pdf.text leadset.email
      end

      pdf.bounding_box( [4.5*72, 8.25*72], width: 3.25*72, height: 0.75*72 ) do
        pdf.text "Notes:"
        pdf.text "Support & various tasks, for the month of #{ month_on.strftime('%B') }."
      end

      lineitems_with_header = [
        [ 'Description', 'Per Unit', '# of Units', 'Subtotal' ]
      ]
      total = 0
      leadset.subscriptions.each do |i|
        subtotal = (i.price.amount_cents * i.quantity).to_f/100
        lineitems_with_header.push([ i.price.product.name, i.price.name_simple, i.quantity, subtotal ])
        total += subtotal
      end


      pdf.move_down 20
      pdf.table(lineitems_with_header, {
        position: :center,
        width: 7.5*72,
        cell_style: {
          inline_format: true,
          borders: [ :bottom ]
        },
      } )

      pdf.table([
        [ 'Total' ],
        [ total ],
      ], {
        position: 7*72,
        width: 1*72,
        cell_style: {
          inline_format: true,
          borders: [ :bottom ]
        },
      } )

      pdf.text_box "Thank you!", at: [ 3.25*72, 1.25*72 ], width: 2*72, height: 1*72, align: :center
    end

    return pdf
  end

end
