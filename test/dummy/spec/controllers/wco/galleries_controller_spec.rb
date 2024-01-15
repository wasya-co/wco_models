
RSpec::describe Wco::GalleriesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users

    Wco::Gallery.unscoped.map &:destroy!
    @gallery = create( :gallery, is_public: true )
  end

  it '#show' do
    get :show, params: { id: @gallery.id }
    response.code.should eql '200'
  end

end

