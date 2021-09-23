
require 'spec_helper'

describe ::Ish::ImageAsset do

  describe 'relations' do
    it { is_expected.to belong_to(:location) }
  end

  it 'is sane' do
    pic = Ish::ImageAsset.new
    pic.should_not eql nil
  end

end

