
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

  it '#preview_str' do
    convo = create(:email_conversation)
    m = create(:email_message, email_conversation: convo)
    m.preview_str.length.should > 0
  end

  describe '#apply_filter' do
    it 'skip inbox' do
      convo = create(:email_conversation)
      msg= create(:email_message, email_conversation: convo, wp_term_ids: [ WpTag.emailtag('inbox').id ] )
      filter = create(:email_filter, subject_regex: 'abba', kind: Office::EmailFilter::KIND_SKIP_INBOX )

      msg.apply_filter( filter )

      msg.wp_term_ids.include?( WpTag.emailtag('inbox').id ).should eql false
    end
  end

end



