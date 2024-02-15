
RSpec::describe Wco::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Lead, Wco::Leadset )
    @lead = create( :lead )

    setup_users
  end

  it '#edit' do
    get :edit, params: { id: @lead.id }
    response.code.should eql '200'
  end

  describe '#index' do
    it 'search' do
      @z_lead_1 = create(:lead, email: 'z@z.com' )
      get :index, params: { q: 'z' }
      response.should redirect_to( lead_path(@z_lead_1.id) )

      @z_lead_2 = create(:lead, email: 'z_2@z.com' )

      get :index, params: { q: 'z' }

      outs = assigns(:leads)
      outs.length.should > 0
      outs.each do |out|
        out.email.include?( 'z' ).should eql true
      end
    end
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

  it '#show' do
    get :show, params: { id: @lead.id }
    response.code.should eql '200'
  end

  it '#update' do
    @z = create(:lead, email: 'z@z.com',
      leadset: create(:leadset, email: 'hm@hm.com'),
    )
    patch :update, params: { id: @z.id, lead: { email: 'a@a.com', tags: [ '' ] } }
    Wco::Lead.find( @z.id ).email.should eql 'a@a.com'
  end

end


