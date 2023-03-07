require 'spec_helper'

describe ::Office::EmailAction do

  it 'sanity' do
    n = ::Office::EmailAction.all.count
    a = ::Office::EmailAction.new
    a.save
    Office::EmailAction.all.count.should eql( n + 1 )
  end

end



