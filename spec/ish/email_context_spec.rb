
require 'spec_helper'

describe ::Ish::EmailContext do

  it 'is sane' do
    tmpl = Ish::EmailTemplate.new
    ctx = Ish::EmailContext.new({ to_email: 'some@email.com', subject: 'ze Subject', body: 'A non-empty body', email_template: tmpl })
    flag = ctx.save
    puts! ctx.errors.full_messages if !flag
    flag.should eql true
  end

end

