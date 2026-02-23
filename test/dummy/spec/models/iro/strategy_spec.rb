
RSpec.describe Iro::Strategy do
  include ActiveSupport::Testing::TimeHelpers

  before do
    destroy_every(
      ::Iro::Position, ::Iro::Purse, ::Iro::Stock, ::Iro::Strategy,
      ::Wco::Profile,
    );

    @leadset = ::Wco::Leadset.find_or_create_by!( company_url: 'wasya.co' )
    @profile = ::Wco::Profile.create( email: 'piousbox@gmail.com', leadset: @leadset )
  end

  ## short NVDA credit spread
  ## 2025-10-11 doing
  ## 2026-02-23 No way.. too complicated - this will be deleted.
=begin
  it '#next_inner_strike_on(expires_on)' do
    @nvda = create( :stock, ticker: 'NVDA', last: 892.0 )
    @strategy = Iro::Strategy.create!({
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
=end

  context 'per-kind calculations' do

    context '#calc_rollp_long_credit_put_spread' do
      before do
        @nvda = create( :stock, ticker: 'NVDA', last: 892.0 )
        @strategy = create(:strategy, stock: @nvda,
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

    ## 2026-02-21 ok
    context '#calc_rollp_short_credit_call_spread' do
      before do
        @msft     = create(:stock, ticker: 'MSFT', last: 397.05)
        @strategy = create(:strategy, stock: @msft,
          buffer_above_water: 10.0,
          threshold_dte: 2,
          threshold_neg_delta: 0.6,
          threshold_netp: 0.99,
          threshold_pos_delta: 0.1,
        );
        @purse    = create( :purse )
        @inner    = create( :option, strike: 420,  begin_price: 1.99, end_price: 0.5, end_delta: -0.2  )
        @outer    = create( :option, strike: 430,  begin_price: 1.86, end_price: 0.25 )
        @position = create( :position, inner: @inner, outer: @outer, purse: @purse, expires_on: '2024-04-19' )
      end
      it 'sanity, default' do
        travel_to Time.zone.local(2024, 04, 1) do
          @strategy.calc_rollp_short_credit_call_spread(@position).class.should eql Array
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.33
        end
      end
      it 'expires soon, does not expire soon' do
        @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.99
        travel_to Time.zone.local(2024, 04, 1) do
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should_not eql 0.99
        end
      end
      it 'buffer above water, not buffer above water' do
        travel_to Time.zone.local(2024, 04, 1) do
          @msft.update_attributes({ last: 410.01 })
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.95
          @msft.update({ last: 409.99 })
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should_not eql 0.95
        end
      end
      it 'threshold_neg_delta' do
        travel_to Time.zone.local(2024, 04, 1) do
          @inner.update({ end_delta: -0.62 })
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.88
        end
      end
      it 'threshold_pos_delta' do
        travel_to Time.zone.local(2024, 04, 1) do
          @inner.update({ end_delta: -0.09 })
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.69
        end
      end
      it 'threshold_netp' do
        travel_to Time.zone.local(2024, 04, 1) do
          @inner.update({ end_price: 0.00 })
          @outer.update({ end_price: 0.00 })
          @strategy.calc_rollp_short_credit_call_spread(@position)[0].should eql 0.51
        end
      end
    end


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

    # it '#net_amount_long_credit_put_spread' do
    #   p = @position
    #   @strategy.net_amount_long_credit_put_spread( p ).should eql( p.inner.begin_price - p.inner.end_price )
    # end

  end

end

