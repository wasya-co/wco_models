require 'spec_helper'

# From: http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

Mongoid.load!("config/mongoid.yml", :test)

describe IshModels do
  describe '#configure' do

    it 'whatever, affects' do
      photo = Photo.create
      photo.persisted?.should eql true
    end

  end
end

         
     
