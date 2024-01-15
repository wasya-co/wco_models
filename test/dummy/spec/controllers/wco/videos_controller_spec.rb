
RSpec::describe Wco::VideosController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users

    Wco::Video.unscoped.map &:destroy!
    @video = create( :video )
  end

  it '#index' do
    get :index
    response.code.should eql '200'
    assigns(:videos).length.should > 0
  end

end

