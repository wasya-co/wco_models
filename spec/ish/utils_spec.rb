
require 'spec_helper'

# it's included in a Gallery

describe 'Ish::Utils' do

  it '#set_slug - when name is empty' do
    a = Gallery.new
    a.save
    a.slug.should eql '1'
  end

end

