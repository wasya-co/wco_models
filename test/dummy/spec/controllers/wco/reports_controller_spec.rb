
RSpec::describe Wco::ReportsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users

    Wco::Report.unscoped.map &:destroy!
    @report = create( :report )
  end

  it '#create' do
    expect {
      post :create, params: { report: { title: 'Abba' } }
    }.to change {
      Wco::Report.all.count
    }.by 1
  end

  it '#show' do
    get :show, params: { id: @report.id }
    response.code.should eql '200'
  end

end

