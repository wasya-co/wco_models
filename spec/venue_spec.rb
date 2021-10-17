require 'spec_helper'

describe Venue do
  before :each do
    do_setup
  end

  describe 'creates/updates' do
    it 'sets slug if not present' do
      @venue = Venue.new( name: 'Some name', city: @city )
      flag = @venue.save
      puts! @venue.errors.full_messages if !flag
      flag.should eql true
      @venue.slug[0...9].should eql 'some-name'
    end
  end

end



