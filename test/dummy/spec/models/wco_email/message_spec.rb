
RSpec.describe WcoEmail::Message do

  before do
    Wco::Lead.unscoped.map &:destroy!

    WcoEmail::Conversation.unscoped.map &:destroy!
    @conv = create(:email_conversation, tags: [ Wco::Tag.inbox ] )
  end

  context 'validations' do

    it 'conversation must be present' do
      m = WcoEmail::Message.create()
      m.persisted?.should eql false
      m.errors.messages[:conversation].include?( "can't be blank" ).should eql true
    end

    it 'message_id is unique and not nil' do
      message_id = 'test'
      WcoEmail::Message.unscoped.map &:delete
      WcoEmail::MessageStub.unscoped.map &:delete
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


  context '#apply_filter_action' do
    before do
      destroy_every( Wco::Lead, Wco::Tag,
        WcoEmail::Conversation,
        WcoEmail::EmailFilter, WcoEmail::EmailFilterAction,
        WcoEmail::EmailTemplate,
        WcoEmail::Message, WcoEmail::MessageStub,
      );
      @conv = create(:email_conversation, tags: [ Wco::Tag.inbox ] )
      @lead = create(:lead)
      @message = create(:email_message, lead: @lead, conversation: @conv, object_key: 'any' )
      @tag_1 = create( :tag )
    end

    it 'KIND_ADD_TAG' do
      faction = build(:email_filter_action, kind: WcoEmail::EmailFilterAction::KIND_ADD_TAG, aject: @tag_1 )
      message = create( :email_message, conversation: @conv, lead: create(:lead) )

      message.apply_filter_action faction
      message.reload
      message.conversation.tag_ids.should eql([ Wco::Tag.inbox.id, @tag_1.id ])
    end

    it 'KIND_RM_TAG' do
      @conv.tags.push @tag_1 ; @conv.save ; @conv.reload
      @conv.tag_ids.should eql([ Wco::Tag.inbox.id, @tag_1.id ])
      faction = build(:email_filter_action, kind: WcoEmail::EmailFilterAction::KIND_RM_TAG, aject:  @tag_1 )
      message = create( :email_message, conversation: @conv, lead: create(:lead) )

      message.apply_filter_action faction
      message.reload
      message.conversation.tag_ids.should eql([ Wco::Tag.inbox.id ])
    end

    it 'KIND_AUTORESPOND' do
      n = WcoEmail::Context.all.count
      @message.apply_filter_action( build( :email_filter_action,
        kind: EFA::KIND_AUTORESPOND, aject: build(:email_template) ))
      WcoEmail::Context.all.count.should eql( n + 1 )
    end

    it 'KIND_OAT, KIND_RM_OAT' do
      n = Wco::OfficeAction.all.count
      oat = create(:oat)
      @message.apply_filter_action( build( :email_filter_action, kind: EFA::KIND_OAT, aject: oat ))
      Wco::OfficeAction.all.count.should eql( n + 1 )
      Wco::OfficeAction.all.last.status.should eql 'active'
      @message.apply_filter_action( build( :email_filter_action, kind: EFA::KIND_RM_OAT, aject: oat ))
      Wco::OfficeAction.all.count.should eql( n + 1 )
      Wco::OfficeAction.all.last.status.should eql 'disabled'
    end

  end

end


=begin

  context '#apply_filter' do
    before do
      WcoEmail::Message.unscoped.map &:destroy!
      WcoEmail::MessageStub.unscoped.map &:destroy!

      Wco::Tag.unscoped.map &:destroy!
      @tag_1 = create( :tag )

      WcoEmail::EmailFilter.unscoped.map &:destroy!
      WcoEmail::EmailTemplate.unscoped.map &:destroy!

      WcoEmail::Conversation.unscoped.map &:destroy!
      @conv = create(:email_conversation, tags: [ Wco::Tag.inbox ] )
    end



    it 'KIND_ADD_TAG spam' do
      filter = create( :email_filter, {
        kind: WcoEmail::EmailFilter::KIND_ADD_TAG,
        tag:  Wco::Tag.spam,
      })
      message = create( :email_message, conversation: @conv, lead: create(:lead) )
      message.conversation.tag_ids.should eql([ Wco::Tag.inbox.id ])

      message.apply_filter filter
      message.reload
      message.conversation.tag_ids.should eql([ Wco::Tag.spam.id ])
    end


    it 'KIND_AUTORESPOND_TMPL' do
      template = create( :email_template )
      filter   = create( :email_filter, {
        kind: WcoEmail::EmailFilter::KIND_AUTORESPOND_TMPL,
        email_template: template,
      })
      message = create( :email_message, conversation: @conv, lead: create(:lead) )

      expect {
        message.apply_filter filter
      }.to change { WcoEmail::Context.all.length }.by( 1 )
    end

    it 'KIND_AUTORESPOND_EACT' do
      tmpl   = create( :email_action_template )
      filter = create( :email_filter, {
        kind: WcoEmail::EmailFilter::KIND_AUTORESPOND_EACT,
        email_action_template: tmpl,
      })
      message = create( :email_message, conversation: @conv, lead: create(:lead) )

      expect {
        message.apply_filter filter
      }.to change { Sch.all.length }.by( 1 )
    end

  end
=end

