
require 'spec_helper'

describe ::Ish::EmailContext do

  it 'is sane' do
    tmpl = Ish::EmailTemplate.new
    ctx = Ish::EmailContext.new({ to_email: 'some@email.com', subject: 'ze Subject',
      body: 'A non-empty body', email_template: tmpl,
      from_email: 'no-reply@infiniteshelter.com',
    })
    flag = ctx.save
    puts!( ctx.errors.full_messages, "Cannot save Ish::EmailContext in test" ) if !flag
    flag.should eql true
  end

end

