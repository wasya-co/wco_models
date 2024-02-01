
##
## In order to have unsubscribes_url , unsubscribes must be in wco .
##
RSpec::describe Wco::UnsubscribesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every(
      Wco::Lead,
      WcoEmail::Unsubscribe,
    )
    setup_users

    @lead        = create( :lead )
    @unsubscribe = create( :unsubscribe, lead: @lead, email: @lead.email )
  end

  # it '#create' do
  #   expect {
  #     post :create, params: { unsubscribe: { title: 'Abba' } }
  #   }.to change {
  #     Wco::Unsubscribe.all.count
  #   }.by 1
  # end

  it '#index' do
    get :index
    response.code.should eql '200'
  end

end

