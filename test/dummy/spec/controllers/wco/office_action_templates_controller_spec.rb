
RSpec::describe Wco::OfficeActionTemplatesController do
  render_views
  routes { Wco::Engine.routes }

  before do
    destroy_every(
      Wco::OfficeAction,
      Wco::OfficeActionTemplate,
    )
    setup_users
  end

  it '#new' do
    get :new
    response.code.should eql '200'
  end

  it '#create, #update' do
    post :update, params: { oat: { slug: 'trash', action_exe: 'print "."' } }
    Wco::OfficeActionTemplate.all.length.should eql 1

    oat = Wco::OfficeActionTemplate.all.first
    post :update, params: { id: oat.id, oat: { action_exe: 'print ".."' } }
    oat.reload
    oat.action_exe.should eql 'print ".."'
  end

end

