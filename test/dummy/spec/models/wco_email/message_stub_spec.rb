
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
        WcoEmail::Message,
        WcoEmail::MessageStub,
      );
      @conv = create(:email_conversation)
      @lead = create(:lead)
    end

    it 'Adds conv to this filter' do
      filter  = create(:email_filter)
      faction = create(:email_filter_action, email_filter: filter)
      fcond   = create(:email_filter_condition, field: 'from', operator: 'match-i', value: 'pudeyev', email_filter: filter )
      filter.conversation_ids.should eql([])

      stub   = create( :message_stub,
        bucket: ::SES_S3_BUCKET,
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process_json

      filter.reload
      filter.conversation_ids.length.should eql 1
    end

    it 'populates preview' do
      stub   = create( :message_stub,
        bucket: ::SES_S3_BUCKET,
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process_json

      conversation = WcoEmail::Conversation.all.last
      conversation.preview[0...100].should eql "logs:root@annesque:/opt/projects/annesque_email#root@annesque:/opt/projects/annesque_email#root@anne"
    end

  end

end
