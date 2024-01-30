
RSpec.describe Wco::Invoice do

  before do
    destroy_every( Wco::Invoice, Wco::Leadset )
  end

  it 'sanity' do
    invoice = Wco::Invoice.create( leadset: create( :leadset ) )
    puts! invoice.errors.messages if !invoice.persisted?
    invoice.persisted?.should eql true
  end

end
