require 'spec_helper'

describe Newsitem do
  before :each do
    do_setup
  end

  describe '#create' do
    it 'does' do
      @newsitem = Newsitem.new
      flag = @newsitem.save
      flag.should eql true
    end
  end

end



