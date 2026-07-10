
RSpec.describe WcoEmail::MessageStub do

  context '#do_process_json' do
    before do
      destroy_every(
        Wco::Lead,
        Wco::Leadset,
        Wco::Tag,
        WcoEmail::Conversation,
        WcoEmail::EmailFilter,
        WcoEmail::EmailTemplate,
        WcoEmail::MessageStub,
      );
      # @conv = create(:email_conversation)
      # @leadset = create(:leadset, email: 'MAILER-DAEMON@amazonses.com' )
      # @not_spam = Wco::Tag.create!({ slug: 'not-spam' })
      # @email_template = create(:email_template)
    end

    it 'Adds conv to this filter' do
      stub   = create( :message_stub,
        bucket: ::SES_S3_BUCKET,
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process_json

      message = create(:email_message, conversation: @conv, lead: @lead )
      filter  = create(:email_filter)
      faction = create(:email_filter_action, email_filter: filter)

      filter.reload
      filter.conversation_ids.should eql([ @conv.id ])
    end

    it 'populates preview' do
      destroy_every( WcoEmail::Conversation )
      stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )

      stub.do_process

      conversation = WcoEmail::Conversation.all.first
      conversation.preview.should eql "Delivery has failed to these recipients or groups: russelldaveggio@hotmail.com The recipient's mailbox is full and can't accept messages now. Please try resending your message later, or contact the rec"
    end

  end

end
