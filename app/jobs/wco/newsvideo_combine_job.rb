
require 'sidekiq'

class Wco::NewsvideoCombineJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform id
    puts! id, 'Newsvideo generate job...'
    @newsvideo = Wco::Newsvideo.find id
    @newsvideo.only_combine
  end

end
