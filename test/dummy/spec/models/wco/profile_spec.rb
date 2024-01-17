

RSpec.describe Wco::Profile do

  it 'sanity' do
    Wco::Profile.unscoped.map &:destroy!
    m = Wco::Profile.create( email: 'test@email.com' )
    m.persisted?.should eql true
  end

end


