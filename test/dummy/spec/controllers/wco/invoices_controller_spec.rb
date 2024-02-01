
RSpec::describe Wco::InvoicesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Invoice, Wco::Leadset )
    setup_users
    @leadset = create(:leadset)
  end

  # it '#edit' do
  #   @invoice = create( :invoice, leadset: @leadset )
  #   get :edit, params: { id: @invoice.id }
  #   response.code.should eql '200'
  # end

  it '#new_stripe' do
    get :new_stripe, params: { leadset_id: @leadset.id }
    response.code.should eql '200'
  end

end


