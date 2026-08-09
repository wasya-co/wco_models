
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

  it '#destroy' do
    leadset = create(:leadset)
    Wco::Leadset.where( id: leadset.id ).length.should eql 1
    delete :destroy, params: { id: leadset.id.to_s }
    Wco::Leadset.where( id: leadset.id ).length.should eql 0
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

  it '#update - with empty serverhost_ids' do
    leadset = create(:leadset)
    lead    = create(:lead, leadset: leadset )

    patch :update, params: { id: leadset.id, leadset: { company_url: 'one' } }
    response.code.should eql '302'
    leadset.reload
    leadset.company_url.should eql 'one'
  end

  it '#update: empty tags' do
    leadset = create(:leadset, tags: [ Wco::Tag.inbox ] )
    leadset.tags.length.should eql 1

    patch :update, params: { id: leadset.id, leadset: { tag_ids: [ '' ] } }

    leadset.reload
    leadset.tags.length.should eql 0
  end

end

