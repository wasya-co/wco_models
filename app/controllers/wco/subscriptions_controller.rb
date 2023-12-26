
class Wco::SubscriptionsController < Wco::ApplicationController

  before_action :set_lists

  ## Alphabetized : )

  ##
  ## A stripe subscription is currently single-item only.
  ##
  def create
    @subscription = Wco::Subscription.new params[:subscription].permit!
    authorize! :create, @subscription

    @subscription.leadset_id = Leadset.where({ customer_id: params[:subscription][:customer_id] }).first&.id
    @subscription.price   = Wco::Price.find_by price_id: params[:subscription][:price_id]
    @subscription.product = @subscription.price.product

    if params[:is_stripe]
      payment_methods = Stripe::Customer.list_payment_methods( params[:subscription][:customer_id] ).data
      params = {
        customer: params[:subscription][:customer_id],
        default_payment_method: payment_methods[0][:id],
        items: [
          { price:    params[:subscription][:price_id],
            quantity: params[:subscription][:quantity],
          },
        ],
      }
      @stripe_subscription = Stripe::Subscription.create( params )
      flash_notice @stripe_subscription
    end


    flag = @subscription.save
    if flag
      flash_notice @subscription
      redirect_to action: :show, id: @subscription.id
    else
      flash_alert @subscription
      redirect_to action: :new
    end
  end


  def index
    authorize! :index, Wco::Subscription

    @stripe_customers     = Stripe::Customer.list().data
    @stripe_subscriptions = Stripe::Subscription.list().data

    @customers     = {} ## still stripe customers
    customer_ids   = @stripe_customers.map &:id
    @leadsets      = Leadset.where( :customer_id.in => customer_ids )
    @leadsets.each do |i|
      @customers[i[:customer_id]] ||= {}
      @customers[i[:customer_id]][:leadsets] ||= []
      @customers[i[:customer_id]][:leadsets].push( i )
    end
    @profiles = Ish::UserProfile.where( :customer_id.in => customer_ids )
    @profiles.each do |i|
      @customers[i[:customer_id]] ||= {}
      @customers[i[:customer_id]][:profiles] ||= []
      @customers[i[:customer_id]][:profiles].push( i )
    end
    # puts! @customers, '@customers'

    @wco_subscriptions = Wco::Subscription.all

  end

  def new
    @subscription = Wco::Subscription.new
    authorize! :new, @subscription
  end

  def new_stripe
    @subscription = Wco::Subscription.new
    authorize! :new, @subscription
  end

  def new_wco
    @subscription = Wco::Subscription.new
    authorize! :new, @subscription
  end

  def show
    @subscription = Wco::Subscription.find params[:id]
    authorize! :show, @subscription
  end

  ##
  ## private
  ##
  private

  def set_lists
    super
    @products_list = Wco::Product.list
    leadsets = Leadset.where( "customer_id IS NOT NULL"         ).map { |i| [ "leadset // #{i.company_url} (#{i.email})", i.customer_id ] }
    profiles = ::Ish::UserProfile.where( :customer_id.ne => nil ).map { |i| [ "profile // #{i.email}", i.customer_id ] }
    @customer_ids_list = leadsets + profiles
    @price_ids_list = Wco::Product.all.includes( :prices ).map do |i|
      price    = i.prices[0]
      if price&.price_id
        puts! price.interval, 'price.interval'
        [ "#{i.name} // $#{price.amount_cents.to_f/100}/#{price.interval||'onetime'}", price.price_id ]
      else
        [ "#{i.name} - no price!!!", nil ]
      end
    end
  end

end
