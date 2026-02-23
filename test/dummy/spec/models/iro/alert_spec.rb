
RSpec.describe Iro::Alert do

  before do
    destroy_every(
      Iro::Alert,
      Iro::Stock,
      Wco::Profile,
    )
    @profile = create(:profile, email: 'piousbox@gmail.com')
    @stock   = create(:stock, ticker: 'META' )
  end

  it 'sanity' do
    a = Iro::Alert.create!( symbol: 'QQQ', direction: 'BELOW', strike: 1.0 )
    a.persisted?.should eql true
  end

  describe '#do_run' do
    it 'sanity' do
      expect( Tda::Stock ).to receive(:get_quote).and_return( ::Iro::Priceitem.new({ last: 10.0 }) )
      @alert = create( :alert, symbol: @stock.ticker, direction: "ABOVE", strike: 0.0 )

      expect( Iro::AlertMailer ).to receive( :stock_alert ).exactly( 1 ).times
      @alert.do_run
    end

    it 'incorrectly retirns string' do
      expect( Tda::Stock ).to receive( :get ).and_return(OpenStruct.new( parsed_response: "" ))
      @alert = create( :alert, symbol: @stock.ticker, direction: "ABOVE", strike: 0.0 )

      expect( ::ExceptionNotifier ).to_not receive( :notify_exception )
      @alert.do_run
    end

    it 'incorrectly returns nil' do
      expect( Tda::Stock ).to receive( :get ).and_return(OpenStruct.new( parsed_response: nil ))
      @alert = create( :alert, symbol: @stock.ticker, direction: "ABOVE", strike: 0.0 )

      expect( ::ExceptionNotifier ).to_not receive( :notify_exception )
      @alert.do_run
    end
  end
end

