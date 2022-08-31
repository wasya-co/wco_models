
require 'spec_helper'

describe ::Ish::EmailContext do

  it 'is sane' do
    ctx = Ish::EmailContext.new
    flag = ctx.save
    flag.should eql true
  end

end

