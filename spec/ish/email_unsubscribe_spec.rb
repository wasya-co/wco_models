
require 'spec_helper'

describe ::Ish::EmailUnsubscribe do

  it 'validations' do
    unsub = Ish::EmailUnsubscribe.new email: 'some@email.com'
    flag = unsub.save
    if !flag
      puts! unsub.errors.full_messages, 'cannot save Ish::Unsubscribe'
    end
    flag.should eql true
  end

end

