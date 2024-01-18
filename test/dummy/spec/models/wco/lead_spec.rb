

RSpec.describe Wco::Lead do

  before do
    destroy_every( Wco::Lead, Wco::Leadset )
  end

  it 'normalizes email' do
    lead = Wco::Lead.create( email: 'abba@zz.com' )
    Wco::Lead.all.length.should eql 1
    Wco::Leadset.all.length.should eql 1
    lead = Wco::Lead.create( email: 'ABBA+1@ZZ.COM' )
    Wco::Lead.all.length.should eql 1
    Wco::Leadset.all.length.should eql 1
  end

end


