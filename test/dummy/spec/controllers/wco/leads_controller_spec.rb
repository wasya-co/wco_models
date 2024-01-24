
RSpec::describe Wco::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Lead )
    setup_users
  end

  it '#edit' do
    @lead = create( :lead )
    get :edit, params: { id: @lead.id }
    response.code.should eql '200'
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

end


