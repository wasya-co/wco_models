##
## this looks like trash. I'm using straight-up html for now.
##
class Wco::NewsproducerController < Wco::ApplicationController

  def canvas
    authorize! :home, Wco
    render layout: false
    # render 'canvas_minimal', layout: false
  end

  def canvas_minimal
    authorize! :home, Wco
    render 'canvas_minimal', layout: false
  end


  def studio_1
    authorize! :home, Wco
    render layout: false
  end

end

