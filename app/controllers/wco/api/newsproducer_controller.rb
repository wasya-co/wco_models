
class Wco::Api::NewsproducerController < Wco::ApiController

  before_action :decode_simple_api_key

  ## trash
  def canvas
    authorize! :home, Wco
    # render 'canvas_minimal'
  end

  ## trash
  def canvas_minimal
    authorize! :home, Wco
    render 'canvas_minimal'
  end

  ##
  ## current
  ##
  def studio_1
    authorize! :home, Wco
  end
  def studio_blue
    authorize! :home, Wco
  end
  def studio_green
    authorize! :home, Wco
  end

end

