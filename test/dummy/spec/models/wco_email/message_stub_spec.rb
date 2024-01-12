
RSpec.describe WcoEmail::MessageStub do

  before do
    # Wco::Lead.unscoped.map &:destroy!
    # WcoEmail::Conversation.unscoped.map &:destroy!
    # @conv = create(:email_conversation)



  end

  context '#do_process' do
    it 'applies filters' do
      WcoEmail::EmailFilter.unscoped.map &:destroy!
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

      WcoEmail::MessageStub.unscoped.map &:destroy!
      stub   = create( :message_stub, bucket: 'ish-ses', object_key: '00nn652jk1395ujdr3l11ib06jam0oevjqv2o4g1' )
      stub.do_process

    end
  end

end
