require 'spec_helper'
describe 'Ish::Lead' do
  before :each do
    do_setup
  end

  it 'has url, phone, normalize phone' do
    lead = Ish::Lead.new :company_url => 'https://some-url.com', :phone => '555 555 5555'
    lead.save
    lead.company_url.should_not eql nil
    lead.phone.should eql 5555555555
  end

end

