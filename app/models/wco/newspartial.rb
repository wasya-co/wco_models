
class Wco::Newspartial
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_newspartials'

  PAGE_PARAM_NAME = 'newspartials_page'

  field :title
  # validates :title, presence: true, uniqueness: true
  index({ title: 1 }, { unique: true })

  field :body
  field :config_json, type: :string, default: '{}'
  field :speech_json, type: :string, default: '{}' # the smaller config, excludes audio wav

  belongs_to :newsvideo
  has_one :video

  def config
    @config ||= JSON.parse self[:config_json]
  end
  def duration_ms
    duration = config['vtimes'].last.to_i + config['vdurations'].last.to_i rescue 0
  end

  def generate_speech
    out = HTTParty.post( "#{HEAD_TTS_ORIGIN}/v1/synthesize",
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
      }, body: {
        input: body,
        voice: "af_bella",
        language: "en-us",
        audioEncoding: "wav",
      }.to_json
    );
    out = out.body
    puts! out, 'out'

    self[:config_json] = out

    tmp = JSON.parse( out )
    tmp.delete('audio')
    self[:speech_json] = tmp.to_json

    self.save
    return out
  end

  def generate_video
    cmd = "cd #{ISHLIB3JS_ROOT} ;
      node ./src/talking_head/example_puppeteer_wired.js \
        --api_key=#{SIMPLE_API_KEY} \
        --api_secret=#{SIMPLE_API_SECRET} \
        --wco_origin=#{WCO_ORIGIN} \
        --newspartial_id=#{self[:id]} ";

    puts! cmd, 'cmd'
    begin
      out = `#{cmd}`
    rescue err
      puts! err, 'err'
    end
    puts! out, 'out'
    return out
  end

  def video
    Wco::Video.where( newspartial_id: self[:id] ).first
  end

end
