require 'spec_helper'

describe Office::Action do

  it 'sanity' do
    n = Office::Action.all.count
    a = Office::Action.new
    a.save
    Office::Action.all.count.should eql( n + 1 )
  end

end



