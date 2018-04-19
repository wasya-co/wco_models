require 'spec_helper'
describe 'Tag' do
  before :each do
    do_setup
  end

  it 'the first blank choice is non-disabled in Tag.list' do
    result = Tag.list
    result[0].length.should eql 2 # no extra characteristics as the 3rd field
  end

end
     
