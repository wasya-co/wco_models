
require 'spec_helper'

describe Office::EmailMessage do

  it 'sanity' do
    n = Office::EmailMessage.all.count
    a = Office::EmailMessage.new( email_conversation: Conv.create )
    a.save
    Office::EmailMessage.all.count.should eql( n + 1 )
  end

  it '#add_tag' do
    tag = ::WpTag.create( name: 'test-name' )
    msg = ::Msg.create( email_conversation: Conv.create, message_id: rand(1_000_000) )
    msg.add_tag( tag )
    msg = Msg.find msg.id
    msg.wp_term_ids.should eql([ tag.id ])
  end

end



