
RSpec.describe WcoEmail::MessageStub do

  before do
    # Wco::Lead.unscoped.map &:destroy!
    # WcoEmail::Conversation.unscoped.map &:destroy!
    # @conv = create(:email_conversation)
  end

  context '#do_process' do
    before do
      destroy_every( Wco::Lead, Wco::Leadset, WcoEmail::MessageStub, WcoEmail::EmailFilter )
    end

    it 'applies filters' do
      filter_params = [
        { from_exact: 'MAILER-DAEMON@amazonses.com' },
        { from_regex: 'amazonses\.com$' },
        { subject_exact: 'undeliverable' },
        { subject_regex: '^U' },
      ]
      filter_params.each do |filter_param|
        # puts! filter_param, 'filter_param'
        filter = create( :email_filter, filter_param )
        expect_any_instance_of( WcoEmail::Message ).to receive( :apply_filter ).exactly(1).times.with( filter )
      end
      stub   = create( :message_stub,
        bucket: 'ish-test-2024',
        object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process
    end

    context 'forwarder_notifies' do
      it 'send for inbox' do
        expect( WcoEmail::ApplicationMailer ).to receive(:forwarder_notify
          ).exactly(1).times.and_return( WcoEmail::ApplicationMailer.forwarder_notify(WcoEmail::Message.all.first.id) )
        stub   = create( :message_stub, bucket: 'ish-test-2024', object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
        stub.do_process
      end

      it 'does not send if not in inbox' do
        filter = create( :email_filter, {
          from_regex: '.',
          kind:       WcoEmail::EmailFilter::KIND_REMOVE_TAG,
          tag:        Wco::Tag.inbox,
        })
        expect( WcoEmail::ApplicationMailer ).to receive(:forwarder_notify).exactly(0).times
        stub = create( :message_stub, bucket: 'ish-test-2024', object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
        stub.do_process
      end
    end
  end

end
