require 'spec_helper'

describe Office::EmailConversation do

  it '#add_tag' do
    tag  = WpTag.emailtag( 'test-name-2' )
    conv = create :email_conversation
    conv.add_tag tag
    conv = Conv.find conv.id
    conv.in_emailtag?( tag ).should eql true
  end

  describe '#apply_filter' do
    it 'skip inbox' do
      conv  = create :email_conversation
      filter = create(:email_filter, {
        kind: Office::EmailFilter::KIND_REMOVE_TAG,
        wp_term_id: WpTag.emailtag(WpTag::INBOX).id,
      })
      conv.apply_filter( filter )
      conv.in_emailtag?( WpTag::INBOX ).should eql false
    end
  end

end

