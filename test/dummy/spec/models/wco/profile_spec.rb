

RSpec.describe Wco::Profile, type: :model do

  it 'sanity' do
    m = Wco::Profile.create!
    m.persisted?.should eql true
  end

end


