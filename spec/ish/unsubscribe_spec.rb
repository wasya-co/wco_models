
require 'spec_helper'

describe ::Ish::Unsubscribe do

  it 'validations' do
    unsub = Ish::Unsubscribe.new email: 'some@email.com'
    flag = unsub.save
    if !flag
      puts! unsub.errors.full_messages, 'cannot save Ish::Unsubscribe'
    end
    flag.should eql true
  end

end

