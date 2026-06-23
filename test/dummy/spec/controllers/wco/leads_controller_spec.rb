require 'csv'

RSpec::describe Wco::LeadsController do
  render_views
  routes { Wco::Engine.routes }

  before do
    setup_users
    destroy_every( Wco::Lead, Wco::Leadset, Wco::Tag )
    @tag     = create( :tag )
    @lead    = create( :lead, tag_ids: [ @tag.id ] )
  end

  it '#create' do
    n = Wco::Lead.all.length
    post :create, params: { lead: {
      email: 'some@email.com',
      name: 'some name',
    } }
    Wco::Lead.all.length.should eql( n + 1 )
  end

  describe '#create_import' do
    let!(:tag1) { Wco::Tag.create!(slug: "Tag-1") }
    let!(:tag2) { Wco::Tag.create!(slug: "Tag-2") }

    let(:csv_content) do
      CSV.generate(headers: true) do |csv|
        csv << ["email", "name", "phone", "address"]
        csv << ["test1@example.com", "Alice", "123", "Addr1"]
        csv << ["test2@example.com", "Bob", "456", "Addr2"]
      end
    end

    let(:file) { Tempfile.new(['leads', '.csv']) }

    before do
      file.write(csv_content)
      file.rewind
    end

    after { file.close! }

    it "creates leads and assigns tags" do
      expect {
        post :create_import, params: { file: Rack::Test::UploadedFile.new(file.path, 'text/csv'),
                                       tags: [tag1.id, tag2.id] }
      }.to change(Wco::Lead, :count).by(2)

      lead = Wco::Lead.find_by(email: "test1@example.com")
      expect(lead.name).to eq("Alice")
      expect(lead.phone).to eq("123")
      expect(lead.tags.map(&:id)).to match_array([tag1.id, tag2.id])
    end
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

  it '#update: email, address, comment' do
    @z = create(:lead,
      email:  'z@z.com',
    )
    patch :update, params: { id: @z.id, lead: {
      address: 'some-addy',
      comment: 'abba zz',
      email: 'a@a.com',
      tag_ids: [ '' ],
    } }
    out = Wco::Lead.find( @z.id )
    out.email.should eql 'a@a.com'
    out.address.should eql 'some-addy'
    out.comment.should eql 'abba zz'
  end

end


