require 'spec_helper'

describe Ish::UserProfile do
  before :each do
    do_setup
  end

  context 'associations' do
    it { is_expected.to have_many(:my_maps) }
    it { is_expected.to have_many(:my_markers) }
  end

  context '#generate' do
    it "doesnt generate if exists" do
      @user = create(:user)
      @profile = create(:profile, email: @user.email)
      n = Ish::UserProfile.unscoped.count
      Ish::UserProfile.generate({
        email: @user.email,
        password: 'test1234',
        role_name: :admin,
      })
      Ish::UserProfile.unscoped.count.should eql n
    end

    it "generates" do
      @new_email = 'new@email.com'
      n = Ish::UserProfile.unscoped.count

      Ish::UserProfile.generate({ email: @new_email, password: 'test1234', role_name: :admin })

      Ish::UserProfile.unscoped.count.should eql(n+1)
    end

  end

end



