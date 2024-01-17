

RSpec.describe Wco::Tag do

  it 'sanity' do
    Wco::Tag.unscoped.map &:destroy!
    m = Wco::Tag.create!( slug: 'test' )
    m.persisted?.should eql true
  end

end


