
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
  field :speech_json, type: :string, default: '{}' # the smaller config, excludes audio wav

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

  ## "am_fenrir", ## good
  ## "af_bella" ## bad
  ## "af_jessica", ## good
  def generate_speech( voice: 'af_bella' )
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

    self[:speech_json] = tmp.to_json

    self.save
    return out
  end

  ##
  ## Can I make do without puppet driver? Probably not: I need the audio worklet.
  ## uses ishlib3js v0.0.2, not 0.1.0!!!
  ## @deprecated, this is being brought into wco_models
  ##
  def generate_video
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

  def video
    Wco::Video.where( newspartial_id: self[:id] ).first
  end

  def to_s
    "#{newsvideo.slug}::#{slug}"
  end

end
