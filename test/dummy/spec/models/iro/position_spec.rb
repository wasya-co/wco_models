
RSpec.describe Iro::Position do
  # include ActiveSupport::Testing::TimeHelpers

  before do
    destroy_every(
      ::Iro::Option,
      ::Iro::Position, ::Iro::Purse,
      ::Iro::Stock,    ::Iro::Strategy,
      ::Wco::Profile,
    );
  end


  context '#net_amount' do
    it 'net_amount_long_credit_put_spread' do
      @purse = create(:purse)
      @stock_meta = create(:stock_meta)
      @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
      @outer = create(:option, begin_price: 1.50, end_price: 1.48 )
      @inner = create(:option, begin_price: 1.99, end_price: 1.79 )
      @position   = create(:position, purse: @purse, strategy: @strategy, inner: @inner, outer: @outer)
      out = @position.net_amount
      out.should eql( 1.99 - 1.5 + 1.48 - 1.79 ) # 0.18
    end
  end

end