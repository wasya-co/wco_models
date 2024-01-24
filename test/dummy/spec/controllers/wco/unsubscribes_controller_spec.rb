
RSpec::describe Wco::UnsubscribesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users

    Wco::Unsubscribe.unscoped.map &:destroy!
    @unsubscribe = create( :unsubscribe )
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

