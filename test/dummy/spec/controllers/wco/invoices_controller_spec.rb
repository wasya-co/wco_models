
RSpec::describe Wco::InvoicesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Invoice )
    setup_users
  end

  it '#edit' do
    @invoice = create( :invoice )
    get :edit, params: { id: @invoice.id }
    response.code.should eql '200'
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

end


