
RSpec.describe WcoHosting::ApplianceTmpl do

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

  it '#create' do
    tmpl = WcoHosting::ApplianceTmpl.create!({
      kind: 'hello_world',
      version: '0.0.0',
      image: 'some-image',
      volume_zip: 'same',
    })
    tmpl.persisted?.should eql true
  end



end


