

RSpec.describe WcoHosting::Appliance, type: :model do

  before do
    Wco::Leadset.unscoped.map &:destroy!
    @leadset    = create( :leadset )
    WcoHosting::Serverhost.unscoped.map &:destroy!
    @serverhost = create( :vbox1, leadsets: [ @leadset ] )
    WcoHosting::ApplianceTmpl.unscoped.map &:destroy!
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


