require 'spec_helper'

describe Office::EmailMessage do

  it 'sanity' do
    n = Office::EmailMessage.all.count
    a = Office::EmailMessage.new
    a.save
    Office::EmailMessage.all.count.should eql( n + 1 )
  end

end



