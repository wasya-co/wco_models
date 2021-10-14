require 'spec_helper'

describe Report do
  before :each do
    do_setup
  end

  describe 'creates/updates' do
    it 'sets slug if not present' do
      @report = Report.new( name: 'Some name' )
      flag = @report.save
      if !flag
        puts! @report.errors.full_mesages
      end
      flag.should eql true
      @report.name_seo.should eql 'some-name'
    end
  end

end



