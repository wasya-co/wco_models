
RSpec.describe WcoEmail::Conversation do

  before do
    Wco::Lead.unscoped.map &:destroy!
    WcoEmail::Conversation.unscoped.map &:destroy!
    @conv = create(:email_conversation)
  end

  context 'validations' do

    it 'conversation must be present' do
      m = WcoEmail::Message.create()
      # puts! m.errors.messages, 'm errors'
      m.persisted?.should eql false
      m.errors.messages[:conversation].include?( "can't be blank" ).should eql true
    end

    it 'message_id is unique and not nil' do
      message_id = 'test'
      WcoEmail::Message.unscoped.map &:delete!
      WcoEmail::MessageStub.unscoped.map &:delete!
      m = WcoEmail::Message.create({
        conversation: @conv,
        object_key: 'abba',
        stub: create( :message_stub, object_key: 'abba' ),
        lead: create( :lead ),
      })
      m.persisted?.should eql false
      m.errors.messages[:message_id].include?( "can't be blank" ).should eql true

      m.message_id = message_id
      m.save
      puts! m.errors.full_messages if !m.persisted?
      m.persisted?.should eql true

      m = WcoEmail::Message.create( conversation: @conv, message_id: message_id )
      m.persisted?.should eql false
      m.errors.messages[:message_id].include?( "is already taken" ).should eql true
    end

  end

end


