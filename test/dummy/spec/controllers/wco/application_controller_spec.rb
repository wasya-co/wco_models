
RSpec::describe Wco::ApplicationController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users
  end

  it '#tinymce' do
    get :tinymce
    response.code.should eql '200'
  end

end

