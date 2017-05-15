require 'spec_helper'

# From: http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

describe IshModels do
  describe '#configure' do
    before do
      IshModels.configure do |config|
        config.s3_credentials = {
          :bucket => 'such-and-such',
          :key => 'some-key',
          :secret => 'some-secret'
        }
      end
    end

    it 'whatever, affects' do
      photo = Photo.create
      photo.persisted?.should eql true
    end

  end
end

         
     
