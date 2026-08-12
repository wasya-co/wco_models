
class Wco::Api::TagsController < Wco::ApiController

  before_action :decode_jwt

  def index
    authorize! :index, Wco::Tag
    @tags = Wco::Tag.all()
  end

end
