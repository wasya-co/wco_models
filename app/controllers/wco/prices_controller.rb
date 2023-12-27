
class Wco::PricesController < Wco::ApplicationController

  def create
    @price   = Wco::Price.new params[:price].permit( :amount_cents, :interval, :product_id )
    authorize! :create, @price

    @price.interval = nil if !params[:price][:interval].present?
    @product        = Wco::Product.find @price.product_id
    stripe_product  = Stripe::Product.retrieve( @product.product_id )
    price_hash = {
      product:     stripe_product.id,
      unit_amount: @price.amount_cents,
      currency:    'usd',
    }
    if @price.interval.present?
      price_hash[:recurring] = { interval: @price.interval }
    end
    stripe_price = Stripe::Price.create( price_hash )
    # puts! stripe_price, 'stripe_price'

    flash_notice 'Created stripe price.'
    @price.product = @product
    @price.price_id = stripe_price[:id]
    if @price.save
      flash_notice @price
    else
      flash_alert @price
    end
    redirect_to controller: :products, action: :index
  end

  def update
    # if !params[:price][:interval].present?
    #   @price.interval = nil
    # end
  end

end

