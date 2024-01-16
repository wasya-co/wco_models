
# require 'httparty'

class Wco::PublishersController < Wco::ApplicationController

  ## Alphabetized : )

  def create
    @publisher = Wco::Publisher.new params[:publisher].permit!
    authorize! :create, @publisher
    if @publisher.save
      flash_notice "Created publisher"
    else
      flash_alert "Cannot create publisher: #{@publisher.errors.messages}"
    end
    redirect_to action: 'index'
  end

  def do_run
    @publisher = Wco::Publisher.find params[:id]
    authorize! :do_run, @publisher

    @publisher.props = OpenStruct.new( JSON.parse params[:publisher][:props] )
    # @publisher.do_run binding
    @publisher.do_run

    flash_notice "Probably ok"

    redirect_to action: 'index'
  end

  def edit
    @publisher = Wco::Publisher.find params[:id]
    authorize! :edit, @publisher
    @sites_list = Wco::Site.list
    @galleries_list  = Wco::Gallery.list
  end

  def index
    authorize! :index, Wco::Publisher
    @publishers = Wco::Publisher.all
  end

  def new
    authorize! :new, Wco::Publisher
    @new_publisher   = Wco::Publisher.new
    @sites_list = Wco::Site.list
    @galleries_list  = Wco::Gallery.list
  end

  def update
    @publisher = Wco::Publisher.find params[:id]
    authorize! :update, @publisher
    if @publisher.update params[:publisher].permit!
      flash_notice "Updated publisher"
    else
      flash_alert "Cannot update publisher: #{@publisher.errors.messages}"
    end
    redirect_to action: 'index'
  end

end
