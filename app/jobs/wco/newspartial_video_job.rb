
require 'sidekiq'
require 'net/ssh'

class Wco::NewspartialVideoJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform id
    puts! id, 'Newspartial video job...'
    @newspartial = Wco::Newspartial.find id
    @newspartial.generate_video
  end

end
