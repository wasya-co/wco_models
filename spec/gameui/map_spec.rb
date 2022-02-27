require 'spec_helper'

describe Gameui::Map do
  before :each do
    do_setup
  end

  it 'sanity' do
    map = Gameui::Map
    (!!map).should eql true
  end

end



