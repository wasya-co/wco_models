
RSpec.describe WcoEmail::MessageStub do

  before do
    destroy_every(
      Wco::Lead,
      Wco::Leadset,
      Wco::Tag,
      WcoEmail::Conversation,
      WcoEmail::EmailTemplate,
    );
    @conv = create(:email_conversation)
    @leadset = create(:leadset, email: 'MAILER-DAEMON@amazonses.com' )
    @not_spam = Wco::Tag.create!({ slug: 'not-spam' })
    @email_template = create(:email_template)
  end

  context '#do_process' do
    before do
      destroy_every(
        WcoEmail::EmailFilter,
        WcoEmail::MessageStub,
      );
    end

    it 'applies filters' do
      filter_params = [
        { from_exact: 'MAILER-DAEMON@amazonses.com' },
        { from_regex: 'amazonses\.com$' },
        { subject_exact: 'undeliverable' },
        { subject_regex: '^U' },
      ]
      filter_params.each do |param|
        filter = create( :email_filter, param )
        expect_any_instance_of( WcoEmail::Message ).to receive( :apply_filter ).exactly(1).times.with( filter )
      end
      stub   = create( :message_stub,
        bucket: ::SES_S3_BUCKET,
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process
    end

    it 'skip filters' do
      filter_params = [
        { from_exact: 'MAILER-DAEMON@amazonses.com', skip_to_exact: 'info-jpmorgan-lfetgfmltj@wasya.co' },
        { from_exact: 'MAILER-DAEMON@amazonses.com', skip_from_regex: 'trashy|amazonses\.com$|^zebras$' },
      ]
      filter_params.each do |param|
        filter = create( :email_filter, param )
        expect_any_instance_of( WcoEmail::Message ).to_not receive( :apply_filter ).exactly(0).times
      end
      stub   = create( :message_stub,
        bucket: ::SES_S3_BUCKET,
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process
    end

    context 'forwarder_notifies' do
      it 'send for inbox' do
        ::NOTIFY_TO_GOOGLE = true
        expect( WcoEmail::ApplicationMailer ).to receive(:forwarder_notify
          ).exactly(1).times.and_return( WcoEmail::ApplicationMailer.forwarder_notify(WcoEmail::Message.all.first.id) )
        stub   = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
        stub.do_process
      end

      it 'does not notify if not in inbox' do
        filter = create( :email_filter, {
          from_regex: '.',
          kind:       WcoEmail::EmailFilter::KIND_REMOVE_TAG,
          tag:        Wco::Tag.inbox,
        })
        expect( WcoEmail::ApplicationMailer ).to receive(:forwarder_notify).exactly(0).times
        stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
        stub.do_process
      end
    end

    ## this is pretty old, I'm moving away from this _vp_ 2026-06-23
    # it 'Applies related conditions: leadset not-has-tag,
    #                skip_conditions:
    #                        actions: remove-tag, add-tag, autorespond' do
    #   n_in_inbox = Wco::Tag.inbox.conversations.length
    #   n_in_inbox.should eql 0
    #   n_in_trash = Wco::Tag.trash.conversations.length
    #   n_in_trash.should eql 0
    #   n_messages = WcoEmail::Message.all.length
    #   filter = WcoEmail::EmailFilter.create!({
    #     conditions_attributes: [
    #       { field:    WcoEmail::EmailFilterCondition::FIELD_LEADSET,
    #         operator: WcoEmail::EmailFilterCondition::OPERATOR_NOT_HAS_TAG,
    #         value:    @not_spam.id },
    #     ],
    #     actions_attributes: [
    #       { kind: EFA::KIND_RM_TAG,      aject: Wco::Tag.inbox },
    #       { kind: EFA::KIND_ADD_TAG,     aject: Wco::Tag.trash },
    #       { kind: EFA::KIND_AUTORESPOND, aject: @email_template },
    #     ],
    #   })
    #   stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
    #   stub.do_process
    #   Wco::Tag.inbox.conversations.length.should eql n_in_inbox
    #   Wco::Tag.trash.conversations.length.should eql n_in_trash
    #   WcoEmail::Message.all.length.should eql( n_messages + 1 )
    # end

    it 'Applies conditions: to,
           skip_conditions:
                   actions: autorespond' do
      message_id = '<010001898e753cc6-f804bb00-f4da-4546-b387-8261caad96da-000000@email.amazonses.com>'
      message   = WcoEmail::Message.unscoped.where( message_id: message_id ).first
      message.delete if message

      n_messages = WcoEmail::Message.all.length
      filter = WcoEmail::EmailFilter.create!({
        conditions_attributes: [
          { field: WcoEmail::EmailFilterCondition::FIELD_TO_OR_CC, operator: EFC::OPERATOR_EQUALS, value: 'info-jpmorgan-lfetgfmltj@wasya.co' },
        ],
        actions_attributes: [
          { kind: ::WcoEmail::EmailFilterAction::KIND_AUTORESPOND, aject: @email_template },
        ],
      })
      stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )

      stub.do_process
      WcoEmail::Message.all.length.should eql( n_messages + 1 )
    end

    ## this is pretty old, I'm moving away from this _vp_ 2026-06-23
    # it 'Applies conditions: to,
    #        skip_conditions: to,
    #                actions: autorespond' do
    #   n_contexts = WcoEmail::Context.all.length
    #   filter = WcoEmail::EmailFilter.create!({
    #     conditions_attributes: [
    #       { field: 'to', operator: 'text-input', value: 'info-jpmorgan-lfetgfmltj@wasya.co' },
    #     ],
    #     skip_conditions_attributes: [
    #       { field: 'to', operator: 'text-input', value: 'info-jpmorgan-lfetgfmltj@wasya.co' },
    #     ],
    #     actions_attributes: [
    #       { kind: ::WcoEmail::EmailFilterAction::KIND_AUTORESPOND, value: @email_template.id },
    #     ],
    #   })
    #   stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
    #   stub.do_process
    #   WcoEmail::Context.all.length.should eql( n_contexts ) # unchanged
    # end

    it 'populates preview' do
      destroy_every( WcoEmail::Conversation )
      stub = create( :message_stub, bucket: ::SES_S3_BUCKET, object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )

      stub.do_process

      conversation = WcoEmail::Conversation.all.first
      conversation.preview.should eql "Delivery has failed to these recipients or groups: russelldaveggio@hotmail.com The recipient's mailbox is full and can't accept messages now. Please try resending your message later, or contact the rec"
    end

  end

end
