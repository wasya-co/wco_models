

RSpec.describe Wco::AiWriter, type: :model do

  before do
    Wco::Report.unscoped.map &:destroy!
  end

  it '#run_headline' do
    expect( Wco::AiWriter ).to receive( :run_prompt ).at_least(:once).and_return('xx test return xx')

    headline = Wco::Headline.new( name: 'some-headline' )

    expect {
      out = Wco::AiWriter.run_headline headline
    }.to change {
      Wco::Report.all.length
    }.by(1)
  end

  ## It would be a lot of mocking, not much functional spec.
  ##
  # it '#run_prompt' do
  # end

end


