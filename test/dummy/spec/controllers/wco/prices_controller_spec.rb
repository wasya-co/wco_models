
RSpec::describe Wco::PricesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every(
      Wco::Leadset,
      Wco::Price,
      Wco::Product,
      WcoHosting::ApplianceTmpl,
    )
    setup_users
  end

  it '#create for appliance_tmpl' do
    appliance_tmpl = create(:appliance_tmpl)
    leadset        = create(:leadset)

    n  = Wco::Price.all.length
    nn = leadset.appliance_tmpl_prices.length

    post :create, params: { price: {
      interval: 'year',
      amount_cents: 2,
      appliance_tmpl_leadset_id: leadset.id,
      product_id: appliance_tmpl.id,
      product_type: appliance_tmpl.class,

    } }
    Wco::Price.all.length.should eql( n + 1 )
    leadset.reload
    leadset.appliance_tmpl_prices.length.should eql( nn + 1 )
  end

  # it '#destroy' do
  #   price = create( :price )
  #   Wco::Price.all.length.should eql 1
  #   delete :destroy, params: { id: price.id }
  #   Wco::Price.all.length.should eql 0
  # end

end

