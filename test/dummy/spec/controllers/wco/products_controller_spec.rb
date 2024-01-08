
RSpec::describe Wco::ProductsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    User.unscoped.map &:destroy!
    Wco::Profile.unscoped.map &:destroy!
    Wco::Leadset.unscoped.map &:destroy!
    @user = create( :user, email: 'piousbox@gmail.com' )
    sign_in @user
  end

  # it '#new' do
  #   get :new
  #   response.code.should eql '200'
  # end

  it '#create' do
    n = Wco::Product.all.length
    post :create, params: { product: { name: 'test-name' } }
    Wco::Product.all.length.should eql( n + 1 )
  end

end

