

RSpec.describe Wco::Leadset, type: :model do

  it 'sanity' do
    m = Wco::Leadset.create!
    m.persisted?.should eql true
  end

end


