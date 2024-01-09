
RSpec::describe Wco::LeadsetsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    User.unscoped.map &:destroy!
    Wco::Profile.unscoped.map &:destroy!
    Wco::Leadset.unscoped.map &:destroy!
    @user = create( :user, email: 'piousbox@gmail.com' )
    sign_in @user
  end

  it '#edit' do
    leadset = create(:leadset)
    get :edit, params: { id: leadset.id }
    response.code.should eql '200'
  end

end

