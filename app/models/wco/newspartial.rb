
require 'mongoid_paperclip'

class Wco::Newspartial
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'wco_newspartials'

  PAGE_PARAM_NAME = 'newspartials_page'

  MAX_WORDS = 30

  field :body
  field :config_json, type: :string, default: '{}'
  ## no longer used. config_json has everything, including default scene config, excluding audio data.
  # field :speech_json, type: :string, default: '{}' # the smaller config, excludes audio wav

  field :voice, type: :string, default: 'af_jessica' ## defaults: 'af_jessica', 'am_fenrir'

  belongs_to :newsvideo

  has_one :video

  has_many :newsvideo_events, class_name: 'Wco::NewsvideoEvent'
  def newsvideo_events
    Wco::NewsvideoEvent.where(newspartial_id: self.id)
  end

  field :slug, type: :string

  has_mongoid_attached_file :audio,
    :storage => :s3,
    :s3_credentials => ::S3_CREDENTIALS,
    :path => "newspartials/:id/audio/:filename",
    :s3_protocol => 'https',
    # :s3_permissions => 'public-read',
    :validate_media_type => false,
    s3_region: ::S3_CREDENTIALS[:region]
  validates_attachment_content_type :audio, content_type: [ /\Aaudio\/.*\z/, ]

  # has_mongoid_attached_file :video,
  #   :storage => :s3,
  #   :s3_credentials => ::S3_CREDENTIALS,
  #   :path => "newspartials/:id/video/:filename",
  #   :s3_protocol => 'https',
  #   :validate_media_type => false,
  #   s3_region: ::S3_CREDENTIALS[:region]
  # validates_attachment_content_type :video, content_type: [ /\Avideo\/.*\Z/, ]

  # has_mongoid_attached_file :thumb,
  #   :storage => :s3,
  #   :s3_credentials => ::S3_CREDENTIALS,
  #   :path => "newspartials/:id/thumb/:filename",
  #   :s3_protocol => 'https',
  #   :validate_media_type => false,
  #   s3_region: ::S3_CREDENTIALS[:region]
  # validates_attachment_content_type :thumb, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", 'application/octet-stream' ]


  def config
    @config ||= JSON.parse self[:config_json]
  end
  def duration_ms
    duration = config['vtimes'].last.to_i + config['vdurations'].last.to_i rescue 0
  end

  ##
  ## "am_fenrir", ## bad
  ## am_michael good
  ## "af_bella" ## bad
  ## "af_jessica", ## good
  ##
  def generate_speech
    out = HTTParty.post( "#{Wco::Setting.get('HEAD_TTS_ORIGIN')}/v1/synthesize",
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
      }, body: {
        input: body,
        voice: voice,
        language: "en-us",
        audioEncoding: "wav",
      }.to_json
    );
    out = out.body
    # puts! out, 'out'

    self[:config_json] = out
    tmp = JSON.parse( out )

    decoded_audio = Base64.decode64( tmp['audio'] )
    temp_file = Tempfile.new(['speech', '.wav'])
    temp_file.binmode
    temp_file.write(decoded_audio)
    temp_file.rewind
    self.audio = temp_file
    temp_file.close
    temp_file.unlink

    tmp.delete('audio')
    tmp.delete('audioEncoding')

    # puts! Wco::Utils.default_studio_config, 'Wco::Utils.default_studio_config'
    tmp.merge!( Wco::Utils.default_studio_config )
    tmp[:active_camera] = Wco::Utils.default_studio_config.key( Wco::Utils.voice_to_avatar(voice) )
    tmp[:active_spot]   = Wco::Utils.default_studio_config.key( Wco::Utils.voice_to_avatar(voice) )
    self[:config_json]  = tmp.to_json
    # puts! tmp, 'tmp'

    self.save!
    return tmp
  end

  ##
  ## Can I make do without puppet driver? Probably not: I need the audio worklet.
  ## uses ishlib3js v0.0.2, not 0.1.0!!!
  ## @deprecated, this is being brought into wco_models
  ##
  def generate_video_bk
    cmd = "cd #{Wco::Setting.get('ISHLIB3JS_ROOT')} ;
      node ./src/talking_head/example_puppeteer_wired.js \
        --api_key=#{Wco::Setting.get('WASYACO_SIMPLE_API_KEY')} \
        --api_secret=#{Wco::Setting.get('WASYACO_SIMPLE_API_SECRET')} \
        --wco_origin=#{Wco::Setting.get('WASYACO_ORIGIN')} \
        --w_px=#{newsvideo.w_px} \
        --h_px=#{newsvideo.h_px} \
        --newspartial_id=#{self[:id]} ";

    puts "+++ cmd:"
    puts cmd
    begin
      out = `#{cmd}`
    rescue err
      puts! err, 'err'
    end
    puts! out, 'out'
    return out
  end
  def generate_video
    Open3.popen3(generate_video_cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.close
      stdout.each_line do |line|
        puts line
      end
      stderr.each_line do |line|
        puts line
      end
      status = wait_thr.value
      puts "Exit status: #{status.exitstatus}"
    end
  end
  def generate_video_cmd
    cmd = "cd #{Wco::Setting.get('PUPPETEER_ROOT')} ; NEWSPARTIAL_URL='#{generate_video_url}' yarn run run_newspartial_1 "
    puts "+++ puppeteer cmd:"
    puts cmd
    cmd
  end
  def generate_video_url
    newspartial = self
    path = Wco::Engine.routes.url_helpers.api_newspartial_config_path({ id: newspartial.id,
      wco_origin: Wco::Setting.get('WASYACO_ORIGIN'),
      api_key:    Wco::Setting.get('WASYACO_SIMPLE_API_KEY'),
      api_secret: Wco::Setting.get('WASYACO_SIMPLE_API_SECRET'),
    })
    "https://#{Wco::Setting.get('WASYACO_ORIGIN')}#{path}"
  end

  def video
    Wco::Video.where( newspartial_id: self[:id] ).first
  end

  def to_s
    "#{newsvideo.slug}::#{slug}"
  end

end
