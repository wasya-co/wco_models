

RSpec.describe Wco::Profile, type: :model do

  it 'sanity' do
    Wco::Profile.all.destroy_all

    m = Wco::Profile.create( email: 'test@email.com' )

    m.persisted?.should eql true
  end

end


