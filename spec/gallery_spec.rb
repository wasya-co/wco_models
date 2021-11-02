require 'spec_helper'

describe Gallery do
  before :each do
    do_setup
  end

  describe '#create' do
    it 'sets slug if not present' do
      @gallery = Gallery.new( name: 'Some name' )
      flag = @gallery.save
      puts! @gallery.errors.full_messages if !flag
      flag.should eql true
      @gallery.slug[0...9].should eql 'some-name'
    end
  end

end



