
RSpec.describe WcoEmail::EmailFilterCondition, type: :model do

  before do
    destroy_every(
      WcoEmail::Conversation,
      WcoEmail::EmailFilter,
      Wco::Lead, Wco::Leadset,
      Wco::Tag,
    )
    @leadset = create( :leadset )
    @lead    = create(:lead, leadset: @leadset)
    @tag     = create( :tag, slug: 'not-spam' )
    @not_tag = create( :tag )
  end

  context '#apply' do
    it 'FIELD_LEADSET OPERATOR__ID' do
      leadset = create( :leadset, company_url: 'one.com' )
      lead    = Wco::Lead.find_or_create_by_email 'sOmE@one.com'
      cond = WcoEmail::EmailFilterCondition.new({
        field:    WcoEmail::EmailFilterCondition::FIELD_LEADSET,
        operator: WcoEmail::EmailFilterCondition::OPERATOR__ID,
        value:    leadset.id.to_s,
      })
      message = WcoEmail::Message.new from: 'sOmE@one.com'

      outs = cond.apply( lead: lead, message: message )
      outs.class.should eql String
    end
  end


  context '#apply - FIELD_FROM' do
    it 'works' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_FROM,
        operator: WcoEmail::EmailFilterCondition::OPERATOR_MATCH,
        value: '@one.',
      })

      @message = WcoEmail::Message.new from: 'sOmE@one.com'

      outs = cond.apply( lead: @lead, message: @message )
      # puts! outs, 'outs'
      outs.class.should eql String
    end
  end

  context '#apply - TAGGED' do
    it 'negative' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_TAGGED,
        value: @tag.id.to_s,
      })

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'not outs'
      outs.class.should eql NilClass
    end
    it 'TAGGED leadset with _id' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_TAGGED,
        value: @tag.id.to_s,
      })

      @leadset.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'outs'
      outs.class.should eql String
    end
    it 'TAGGED leadset with slug' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_TAGGED,
        value: @tag.slug,
      })

      @leadset.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'outs'
      outs.class.should eql String
    end
    it 'TAGGED lead with _id' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_TAGGED,
        value: @tag.id.to_s,
      })

      @lead.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'outs'
      outs.class.should eql String
    end
  end



  context '#apply - NOT_TAGGED' do
    it 'negative with _id, leadset is tagged' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED,
        value: @tag.id.to_s,
      })

      @leadset.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'not outs'
      outs.class.should eql NilClass
    end
    it 'negative with _id, lead is tagged' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED,
        value: @tag.id.to_s,
      })

      @lead.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'not outs'
      outs.class.should eql NilClass
    end
    it 'negative with slug, leadset is tagged' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED,
        value: @tag.slug,
      })

      @leadset.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'not outs'
      outs.class.should eql NilClass
    end
    it 'negative with slug, lead is tagged' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED,
        value: @tag.slug,
      })

      @lead.tags << @tag

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'not outs'
      outs.class.should eql NilClass
    end

    it 'NOT_TAGGED with _id' do
      cond = WcoEmail::EmailFilterCondition.new({
        field: WcoEmail::EmailFilterCondition::FIELD_NOT_TAGGED,
        value: @tag.id.to_s,
      })

      outs = cond.apply( lead: @lead, message: {} )
      # puts! outs, 'outs'
      outs.class.should eql String
    end
  end

end


