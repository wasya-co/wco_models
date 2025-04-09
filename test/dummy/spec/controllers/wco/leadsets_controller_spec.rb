
RSpec::describe Wco::LeadsetsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every(
      Wco::Lead, Wco::Leadset,
      Wco::Price,
    );
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

  it '#show, non-zero leads' do
    leadset = create(:leadset)
    lead    = create(:lead, leadset: leadset )

    get :show, params: { id: leadset.id }

    response.code.should eql '200'
    assigns(:leads).length.should > 0
  end

end

