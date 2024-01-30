
RSpec::describe Wco::ProductsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( User, Wco::Leadset,
      Wco::Profile, Wco::Product )

    @user = create( :user, email: 'piousbox@gmail.com' )
    sign_in @user
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

  it '#create' do
    n = Wco::Product.all.length
    post :create, params: { product: { name: 'test-name' } }
    Wco::Product.all.length.should eql( n + 1 )
  end

  it '#destroy' do
    product = create( :product )
    Wco::Product.all.length.should eql 1
    delete :destroy, params: { id: product.id }
    Wco::Product.all.length.should eql 0
  end

end

