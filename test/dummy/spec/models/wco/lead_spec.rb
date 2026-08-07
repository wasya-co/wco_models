

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

  it '#find_or_create_by_email' do
    email = 'sOmE@eMaIl.com'
    n = Wco::Lead.all.length
    n.should eql 0
    one = Wco::Lead.find_or_create_by_email( email )
    Wco::Lead.all.length.should eql 1
    one = Wco::Lead.find_or_create_by_email( email )
    Wco::Lead.all.length.should eql 1
  end

  it 'uses existing leadset, WITH a non-standard domain' do
    email = 'abba+zz@one.two.three.four.co.uk'
    one = Wco::Lead.find_or_create_by_email( email )
    n_leadsets = Wco::Leadset.all.length
    email = 'abba3+zz@two.three.four.co.uk'
    two = Wco::Lead.find_or_create_by_email( email )
    Wco::Leadset.all.length.should eql( n_leadsets )
  end

  it 'uses a pre-existing non-root domain' do
    email   = 'abba+zz@one.two.three.four.co.uk'
    leadset = Wco::Leadset.create( company_url: 'one.two.three.four.co.uk' )

    lead = Wco::Lead.find_or_create_by_email( email )
    lead.leadset.should eql leadset
  end

end


