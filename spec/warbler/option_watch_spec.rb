require 'spec_helper'

describe Warbler::OptionWatch do
  before do
    @fields = %i| contractType strike ticker date |
  end

  describe '#create' do
    it 'validations' do
      option_watch = create(:option_watch)
      @fields.each do |f|
        option_watch.should validate_presence_of( f )
      end
    end

    it 'fields' do
      option_watch = create(:option_watch)
      @fields.each do |f|
        option_watch[f].should_not eql( nil ), "#{f} cannot be empty"
      end
    end
  end

end



