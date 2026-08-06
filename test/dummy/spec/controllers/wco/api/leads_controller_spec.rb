
Wco::ApiController::AWS_SES_LAMBDA_SECRET ||= 'secret'

RSpec::describe Wco::Api::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users
    destroy_every( Wco::Lead, Wco::Leadset )
  end

  it '#by_email, exists and doesnt exist' do
    Wco::Lead.all.length.should eql 0
    Wco::Leadset.all.length.should eql 0

    get :by_email, params: { email: 'abba+z1@one.two.three.com', secret: 'secret' }
    json = JSON.parse(response.body)

    get :by_email, params: { email: 'abba-1+z1@two.three.com', secret: 'secret' }
    get :by_email, params: { email: 'abba-2+z1@three.com', secret: 'secret' }

    Wco::Lead.all.length.should eql 3
    Wco::Leadset.all.length.should eql 1
  end

end

