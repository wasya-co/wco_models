
RSpec.describe Iro::Strategy do
  include ActiveSupport::Testing::TimeHelpers

  before do
    destroy_every(
      ::Iro::Position, ::Iro::Purse, ::Iro::Stock, ::Iro::Strategy,
      ::Wco::Profile,
    );

    @leadset   = ::Wco::Leadset.find_or_create_by!( company_url: 'wasya.co' )
    @profile = ::Wco::Profile.create( email: 'piousbox@gmail.com', leadset: @leadset,
      schwab_access_token: TEST_SCHWAB_ACCESS_TOKEN )
  end

  ## short NVDA credit spread
  ## 2025-10-11 doing
  it '#next_inner_strike(expires_on)' do
    @nvda = create( :stock, ticker: 'NVDA', last: 892.0 )
    @strategy = Iro::Strategy.create!({
      # slug: 'xxTestxx',
      kind: Iro::Strategy::KIND_SHORT_CREDIT_CALL_SPREAD,
      long_or_short: Iro::Strategy::SHORT,
      stock: @nvda,

      next_inner_delta: 0.15,
      next_inner_strike: 900,
      next_buffer_above_water: 0,
    })
    out = @strategy.next_inner_strike_on( '2025-10-17' )
    out.should eql 920
  end

  context 'per-kind calculations' do

    context '#max_loss_spread' do
      before do
        @nvda = create( :stock, ticker: 'NVDA', last: 892.0 )
        @strategy = create( :strategy, stock: @nvda )
        @inner    = create( :option, strike: 90,  begin_price: 1.99, end_price: 0.5  )
        @outer    = create( :option, strike: 101, begin_price: 1.86, end_price: 0.25 )
        @purse    = create( :purse )
        @position = create( :position, inner: @inner, outer: @outer, purse: @purse )
      end

      it 'does' do
        travel_to Time.zone.local(2024, 04, 1) do
          @strategy.max_loss_spread( @position ).should eql( @outer.strike - @inner.strike )
        end
      end
    end

    # it '#max_gain_short_credit_call_spread' do
    #   ( @strategy.max_gain_short_credit_call_spread( @position ) - 0.13 ).should < EPSILON
    # end

    # it '#max_loss_short_credit_call_spread' do
    #   @strategy.max_loss_short_credit_call_spread( @position ).should eql 11.0
    # end

    # it '#net_amount_short_credit_call_spread' do
    #   @strategy.net_amount_short_credit_call_spread( @position ).should eql( 1.99 - 0.5 - 1.86 + 0.25 )
    # end

    it '#net_amount_long_credit_put_spread' do
      p = @position
      @strategy.net_amount_long_credit_put_spread( p ).should eql( p.inner.begin_price - p.inner.end_price )
    end

    context '#calc_rollp_long_credit_put_spread' do
      before do
        @nvda = create( :stock, ticker: 'NVDA', last: 892.0 )
        @strategy = create( :strategy, stock: @nvda,
          buffer_above_water: 10.0,
          threshold_netp: 0.99,
          threshold_pos_delta: 0.1 )
        @inner    = create( :option, strike: 90,  begin_price: 1.99, end_price: 0.5  )
        @outer    = create( :option, strike: 101, begin_price: 1.86, end_price: 0.25 )
        @purse    = create( :purse )
        @position = create( :position, inner: @inner, outer: @outer, purse: @purse, expires_on: '2024-04-19' )
      end
      it 'no opinion' do
        travel_to Time.zone.local(2024, 04, 1) do
          @strategy.calc_rollp_long_credit_put_spread(@position).should eql([0.33, '-'])
        end
      end
      it 'threshold_netp: made enough profit' do
        @strategy.update( threshold_netp: 0.73 )
        travel_to Time.zone.local(2024, 04, 1) do
          @strategy.calc_rollp_long_credit_put_spread(@position).should eql([0.51, "made enough 74.87% profit^"])
        end
      end
    end

  end

end

