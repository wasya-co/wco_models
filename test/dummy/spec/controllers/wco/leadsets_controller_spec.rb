
RSpec::describe Wco::LeadsetsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Leadset )
    setup_users
  end

  it '#edit' do
    leadset = create(:leadset)
    get :edit, params: { id: leadset.id }
    response.code.should eql '200'
  end

  describe '#index' do
    it 'search' do
      get :index, params: { q: 'class' }
      response.code.should eql '200'
    end
  end

end

