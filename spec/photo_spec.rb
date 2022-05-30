
require 'spec_helper'

describe Report do
  before :each do
    do_setup
  end

  it 'can belong to a location' do 
    Photo.reflect_on_association(:itemable).class.should eql Mongoid::Association::Referenced::BelongsTo
  end

  it 'photo' do
    photo = Photo.create
    puts! photo.errors.full_messages if !photo.persisted?
    photo.persisted?.should eql true
  end

end