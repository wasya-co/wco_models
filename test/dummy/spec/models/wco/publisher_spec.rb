

RSpec.describe Wco::Publisher do

  before do
    destroy_every( Wco::Publisher, Wco::Report, Wco::Site )
    @report = create(:report)
  end

  it '#do_run' do
    publisher = create(:publisher_pi_drup_prod_report)
    publisher.props = { report_id: @report.id.to_s }
    publisher.do_run
  end

end


