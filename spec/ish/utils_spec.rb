
require 'spec_helper'

# Included in a Gallery

describe 'Ish::Utils' do

  it '#set_slug - when name is empty' do
    Gallery.unscoped.destroy_all
    a = Gallery.new
    a.save
    a.slug.should eql '1'
    a = Gallery.new
    a.save
    a.slug.should eql '2'
  end

end

