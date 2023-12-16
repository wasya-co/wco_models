

RSpec.describe WcoHosting::Appliance, type: :model do

  it 'sanity' do
    m = WcoHosting::Appliance.create!
    m.persisted?.should eql true
  end

  describe 'callbacks' do
    it 'generates name, preserves name if given' do
      m = WcoHosting::Appliance.create!
      assert m.name

      m = WcoHosting::Appliance.create! name: 'some-name'
      m.name.should eql 'some-name'
    end
  end


end


