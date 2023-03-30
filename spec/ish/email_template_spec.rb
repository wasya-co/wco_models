
require 'spec_helper'

describe ::Ish::EmailTemplate do

  it '#blank' do
    blank = Tmpl.blank_template
    blank.persisted?.should eql true
    blank.slug.should eql Tmpl::SLUG_BLANK
  end

end

