
require 'sidekiq'

class Wco::NewsvideoGenerateJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform id
    puts! id, 'Newsvideo generate job...'
    @newsvideo = Wco::Newsvideo.find id
    @newsvideo.generate
  end

end
