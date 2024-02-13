
RSpec.describe WcoHosting::Appliance do

  before do
    destroy_every(
      Wco::Leadset,
      WcoHosting::ApplianceTmpl,
      WcoHosting::Serverhost,
    )
    @leadset    = create( :leadset )
    @serverhost = create( :vbox1, leadsets: [ @leadset ] )
    @tmpl       = create( :hw0_tmpl )
    @appliance  = create( :appliance, {
      appliance_tmpl: @tmpl,
      leadset: @leadset,
      serverhost: @serverhost,
    })
  end

  it 'set_service_name' do
    app = WcoHosting::Appliance.create({
      appliance_tmpl: @tmpl,
      domain: 'b',
      leadset: @leadset,
      serverhost: @serverhost,
      subdomain: 'a',
      subscription: create( :subscription, leadset: @leadset ),
    })
    if !app.persisted?
      puts! app.errors.full_messages, 'Cannot save an appliance'
    end
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


