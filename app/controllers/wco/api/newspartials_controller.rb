
class Wco::Api::NewspartialsController < Wco::ApiController

  before_action :decode_simple_api_key

  ##
  ## PUT config, actually
  ##
  def add_config
    puts! params, 'api newspartials#add_config params'

    @newspartial = Wco::Newspartial.find params[:id]
    authorize! :create, @newspartial

    raw_payload = request.raw_post
    # parsed_payload = JSON.parse(raw_payload)
    @newspartial.config_json = raw_payload

    if @newspartial.save
      puts! @newspartial, 'added config to a newspartial.'
      flash[:notice] = 'Success'
      render json: { status: :ok, message: 'added config to a newspartial.' }
    else
      flash[:alert] = 'No luck'
      render json: { status: :not_ok, message: "Could not add config to newspartial: #{@newspartial.errors.full_messages.join(', ')}." }
    end
  end


  def create
    puts! params, 'api newspartials#create params'

    @newspartial = Wco::Newspartial.new params[:newspartial].permit!
    @newspartial.author = Wco::Profile.find_by email: current_user.email
    authorize! :create, @newspartial

    if @newspartial.save
      puts! @newspartial, 'Created a newspartial.'
      flash[:notice] = 'Success'
      render json: { status: :ok, message: @newspartial.attributes }
    else
      flash[:alert] = 'No luck'
      render json: { status: :not_ok, message: "Could not create a newspartial: #{@newspartial.errors.full_messages.join(', ')}." }
    end
  end

  def show_config
    @newspartial = Wco::Newspartial.find params[:id]
    config = JSON.parse @newspartial.speech_json
    config[:w_px] = @newspartial.newsvideo.w_px
    config[:h_px] = @newspartial.newsvideo.h_px
    config[:slug] = "#{@newspartial.newsvideo.slug}::#{@newspartial.slug}"
    render json: config
  end

end
