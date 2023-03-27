require 'spec_helper'

describe ::Office::EmailAction do

  it 'sanity' do
    n = ::Office::EmailAction.all.length
    a = ::Office::EmailAction.new({ email_template: create(:email_template) })
    a.save
    puts! a.errors.full_messages if !a.persisted?
    Office::EmailAction.all.count.should eql( n + 1 )
  end

end



