

RSpec.describe Wco::Profile do

  it 'sanity' do
    destroy_every Wco::Leadset, Wco::Profile
    leadset = create( :leadset )
    m = Wco::Profile.create( email: 'test@email.com', leadset: leadset )
    m.persisted?.should eql true
  end

end


