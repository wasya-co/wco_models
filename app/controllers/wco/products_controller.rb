
class Wco::ProductsController < Wco::ApplicationController

  # before_action :set_lists

  # Alphabetized : )

  def create
    @product = Wco::Product.new params[:product].permit( :name )
    authorize! :create, @product

    stripe_product = Stripe::Product.create({ name: @product.name })
    # puts! stripe_product, 'stripe_product'
    flash_notice 'Created stripe product.'
    @product.product_id = stripe_product[:id]

    if @product.save
      flash_notice 'Created wco product.'
    else
      flash_alert "Cannot create wco product: #{@product.errors.full_messages.join(', ')}."
    end
    redirect_to action: :index
  end

  def destroy
    authorize! :destroy, Wco::Product
    # product = Wco::Product.find params[:id]

    flag = Stripe::Product.delete( params[:id] )
    # puts! flag, 'flag'
    flash[:notice] = flag
    # if product.destroy
    #   flash[:notice] = 'Success'
    # else
    #   flash[:alert] = "Cannot destroy product: #{product.errors.fill_messages.join(', ')}."
    # end
    redirect_to action: :index
  end

  def edit
    @product = Wco::Product.find params[:id]
    authorize! :edit, @product
  end

  def index
    authorize! :index, Wco::Product

    @stripe_products  = {}
    @_stripe_products = Stripe::Product.list().data
    @_stripe_prices   = Stripe::Price.list().data

    @_stripe_products.each do |sp|
      @stripe_products[sp[:id]] = sp
      @stripe_products[sp[:id]][:prices] ||= {}
    end
    @_stripe_prices.each do |price|
      begin
        @stripe_products[price[:product]][:prices][price[:id]] = price
      rescue Exception
        nil
      end
    end

    @wco_products = Wco::Product.all.includes( :prices )
    @wco_products.each do |item|
      if @stripe_products[item[:product_id]]
        @stripe_products[item[:product_id]][:wco_product] = item
      end
    end

    ## 2023-09-07 @TODO: move to model:
    ##   @wco_prices_hash = Wco::Price.all.hash_by( :price_id )
    ##
    @wco_prices_hash = {}
    @wco_prices = Wco::Price.all
    @wco_prices.each do |item|
      @wco_prices_hash[item[:price_id]] = item
    end

  end

  def show
    authorize! :show, @product
    @product = Wco::Product.find params[:id]
  end

  def update
    authorize! :edit, @product
    @product = Wco::Product.find params[:id]

    if @product.update_attributes params[:product].permit!
      flash[:notice] = 'Success.'
      redirect_to action: :show, id: @product.id
    else
      flash[:alert] = "No luck: #{@product.errors.full_messages.join(', ')}."
      render action: :edit
    end

  end

  ##
  ## private
  ##
  private

end
