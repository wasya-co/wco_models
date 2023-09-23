
require 'spec_helper'

describe Office::EmailMessage do

  it 'sanity' do
    n = Office::EmailMessage.all.count
    a = Office::EmailMessage.new( email_conversation: Conv.create )
    a.save
    Office::EmailMessage.all.count.should eql( n + 1 )
  end


  it '#preview_str' do
    convo = create(:email_conversation)
    m     = create(:email_message, email_conversation: convo)
    m.preview_str.length.should > 0
  end


end



