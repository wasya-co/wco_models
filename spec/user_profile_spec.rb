require 'spec_helper'

describe IshModels::UserProfile do
  before :each do
    do_setup
  end

  it '#current_order' do
    @user_profile.current_order.class.name.should eql 'CoTailors::Order'
  end

end

         
     
