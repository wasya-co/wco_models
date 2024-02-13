
class Wco::PricesController < Wco::ApplicationController

  def create
    @price   = Wco::Price.new params[:price].permit!
    authorize! :create, @price

    @price.interval = nil if !params[:price][:interval].present?
    @product        = params[:price][:product_type].constantize.find @price.product_id
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
    # flash_notice 'Created stripe price.'
    flash_notice stripe_price

    @price.product  = @product
    @price.price_id = stripe_price[:id]
    if @price.save
      flash_notice @price
    else
      flash_alert @price
    end
    case @product.class.name
    when 'WcoHosting::ApplianceTmpl'
      redirect_to request.referrer || root_path
    when 'Wco::Product'
      redirect_to controller: :products, action: :index
    end
  end

  def destroy
    @price = Wco::Price.find params[:id]
    authorize! :destroy, @price
    flag = @price.delete
    if flag
      flash_notice 'ok'
    else
      flash_alert @price
    end
    redirect_to request.referrer || root_path
  end

  def update
    # if !params[:price][:interval].present?
    #   @price.interval = nil
    # end
  end

end

