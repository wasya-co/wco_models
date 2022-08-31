
require 'spec_helper'

describe ::Ish::Meeting do

  it 'is sane' do
    meeting = Ish::Meeting.new
    flag = meeting.save
    flag.should eql true
  end

end

