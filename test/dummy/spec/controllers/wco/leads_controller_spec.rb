
RSpec::describe Wco::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every( Wco::Lead )
    @lead = create( :lead )

    setup_users
  end

  it '#edit' do
    get :edit, params: { id: @lead.id }
    response.code.should eql '200'
  end

  describe '#index' do
    it 'search' do
      @z_lead = create(:lead, email: 'z@z.com' )

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

end


