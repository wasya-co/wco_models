

RSpec.describe WcoHosting::Appliance, type: :model do

  before do
    Wco::Leadset.destroy_all
    @leadset    = create( :leadset )
    WcoHosting::Serverhost.destroy_all
    @serverhost = create( :vbox1, leadsets: [ @leadset ] )
    WcoHosting::ApplianceTmpl.destroy_all
    @tmpl       = create( :hw0_tmpl )
    @appliance  = create( :appliance, serverhost: @serverhost, leadset: @leadset, appliance_tmpl: @tmpl )
  end

  it 'set_service_name' do
    app = WcoHosting::Appliance.create( subdomain: 'a', domain: 'b',
      serverhost: @serverhost, leadset: @leadset, appliance_tmpl: @tmpl )
    app.persisted?.should eql true
    app.service_name.should eql "a_b"
  end

  # it 'sanity' do
  #   m = WcoHosting::Appliance.create!
  #   m.persisted?.should eql true
  # end

  # describe 'callbacks' do
  #   it 'generates name, preserves name if given' do
  #     m = WcoHosting::Appliance.create!
  #     assert m.name

  #     m = WcoHosting::Appliance.create! name: 'some-name'
  #     m.name.should eql 'some-name'
  #   end
  # end


end


