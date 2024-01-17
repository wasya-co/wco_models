
RSpec::describe Wco::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

end


