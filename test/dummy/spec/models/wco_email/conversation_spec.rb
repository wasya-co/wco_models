
RSpec.describe WcoEmail::Conversation, type: :model do

  before do
    WcoEmail::Conversation.all.destroy_all

    Wco::Tag.all.destroy_all
    @tag = Wco::Tag.create( slug: 'test-tag' )
  end

  it 'has tags' do
    c = WcoEmail::Conversation.create( subject: 'test-1', tags: [ @tag ] )
    c.persisted?.should eql true
  end

end


