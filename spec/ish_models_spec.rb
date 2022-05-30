require 'spec_helper'

# From: http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

Mongoid.load!("config/mongoid.yml", :test)

describe IshModels do
  describe '#configure' do

    skip 'sanity' do
    end

  end
end



