
RSpec.describe WcoHosting::Serverhost, type: :model do

  before do
    Wco::Leadset.destroy_all
    @leadset    = create( :leadset )
    @serverhost = create( :vbox1, leadset: @leadset )
    WcoHosting::ApplianceTmpl.destroy_all
    @tmpl       = create( :hw0_tmpl )
    @appliance  = create( :appliance, serverhost: @serverhost, leadset: @leadset, appliance_tmpl: @tmpl )
  end

  # it '#create_appliance' do
  #   out = @serverhost.create_appliance( @appliance )
  # end

  it '#create_volume' do
    out = @serverhost.create_volume( @appliance )
    out.statuses.should eql([ 0, 0 ])
  end


end



