
class Wco::NewspartialSpeechJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform id
    puts! id, 'Newspartial speech job...'
    @newspartial = Wco::Newspartial.find id
    @newspartial.generate_speech
  end

end
