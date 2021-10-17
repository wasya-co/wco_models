require 'spec_helper'

describe Report do
  before :each do
    do_setup
  end

  describe 'creates/updates' do
    it 'sets slug if not present' do
      @report = Report.new( name: 'Some name' )
      flag = @report.save
      puts! @report.errors.full_messages if !flag
      flag.should eql true
      @report.slug[0...9].should eql 'some-name'
    end
  end

end



