

RSpec.describe Wco::Tag, type: :model do

  it 'sanity' do
    m = Wco::Tag.create!
    m.persisted?.should eql true
  end

end


