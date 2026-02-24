
RSpec.describe Iro::Position do
  # include ActiveSupport::Testing::TimeHelpers

  before do
    destroy_every(
      ::Iro::Option,
      ::Iro::Position, ::Wco::Profile,   ::Iro::Purse,
      ::Iro::Stock,    ::Iro::Strategy,
    );
  end

  context 'breakeven' do
    before do
      @stock    = create(:stock, ticker: 'META')
      @strategy = create(:strategy, kind: Iro::Strategy::KIND_LONG_DEBIT_CALL_SPREAD)
    end

    it '#breakeven_long_credit_put_spread' do
      @pos  = Iro::Position.create({
        status: 'active',
        expires_on: '2024-01-01',
        quantity: 1,

        stock: @stock,
        strategy: @strategy,

        outer: create(:option, stock: @stock, strike: 9,  begin_price: 0.6, end_price: 0.6),
        inner: create(:option, stock: @stock, strike: 10, begin_price: 0.8, end_price: 0.8),
      })
      expected = @pos.inner.strike + @pos.outer.begin_price - @pos.inner.begin_price
      ( @pos.breakeven_long_credit_put_spread - expected ).should < EPSILON
    end
  end


  context '#calc_rollp' do
    it 'sanity' do
    end
  end

  context '#net_amount' do
    before do
      @stock_meta = create(:stock, ticker: 'META')
    end

    it 'net_amount_long_credit_put_spread' do
      @purse      = create(:purse)
      @strategy   = create(:strategy_long_credit_put_spread, stock: @stock_meta)
      @outer = create(:option, begin_price: 1.50, end_price: 1.48 )
      @inner = create(:option, begin_price: 1.99, end_price: 1.79 )
      @position   = create(:position, purse: @purse, strategy: @strategy, inner: @inner, outer: @outer)
      out = @position.net_amount
      out.should eql( 1.99 - 1.5 + 1.48 - 1.79 ) # 0.18
    end

    it 'net_amount_short_credit_call_spread' do
      @purse      = create(:purse)
      @strategy   = create(:strategy, kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD, stock: @stock_meta)
      @inner      = create(:option, begin_price: 1.99, end_price: 1.79 )
      @outer      = create(:option, begin_price: 1.50, end_price: 1.48 )
      @position   = create(:position, purse: @purse, strategy: @strategy, inner: @inner, outer: @outer)
      out = @position.net_amount
      out.should eql( 1.99 - 1.5 + 1.48 - 1.79 ) # 0.18
    end

    it '#net_amount, short credit call spread (2) ' do
      @pos = Iro::Position.create({
        status: 'active',
        expires_on: '2024-01-01',
        quantity: 2,
        stock: @stock,
        strategy: create(:strategy,
          kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD,
          stock: @stock ),

        inner: create( :option, begin_price: 0.6, end_price: 0.99 ),
        outer: create( :option, begin_price: 0.8, end_price: 0.7 ),
      })
      expected = 0.6 - 0.99 - 0.8 + 0.7
      ( @pos.net_amount - expected ).should < EPSILON
    end

  end

end