

RSpec.describe Wco::Leadset do

  before do
    Wco::Leadset.unscoped.map &:destroy!
  end

  it 'sanity' do
    m = Wco::Leadset.create( company_url: 'abba.com' )
    m.persisted?.should eql true
  end

end


