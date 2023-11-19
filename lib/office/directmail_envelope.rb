require 'prawn'

class Office::DirectmailEnvelope
  include Mongoid::Document
  include Mongoid::Timestamps


  ## 72 points per inch
  ## 72 ppi
  def self.list_to_envelopes props
    from = props[:from]

    pdf = Prawn::Document.new({ page_size: [ 9.5*72, 4.12*72 ], :margin => [0,0,0,0] })

    pdf.canvas do

      props[:tos].each_with_index do |to, idx|
        print '.'

        pdf.bounding_box( [  0.5*72, 3.5*72 ], width: 3*72, height: 2*72 ) do
          # pdf.transparent(0.5) { pdf.stroke_bounds }

          pdf.text from[:name]
          pdf.text from[:address_1]
          pdf.text from[:address_2]
          pdf.text from[:address_3]
        end

        pdf.bounding_box( [ 4*72, 2.5*72 ], width: 4*72, height: 2*72 ) do
          # pdf.transparent(0.5) { pdf.stroke_bounds }

          pdf.text to[:name]
          pdf.text to[:address_1]
          pdf.text to[:address_2]
          pdf.text to[:address_3]
        end

        if idx+1 != props[:tos].length
          pdf.start_new_page
        end

      end

    end

    return pdf
  end

end
ODE = ::Office::DirectmailEnvelope

