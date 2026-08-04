
class Wco::Setting
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_settings'

  KEYS = [ 'HEAD_TTS_ORIGIN', 'ISHLIB3JS_ROOT',
    'OPENAI_API_KEY', 'PEXELS_API_KEY',
    'WASYACO_ORIGIN', 'WASYACO_SIMPLE_API_KEY', 'WASYACO_SIMPLE_API_SECRET',
  ];

  field :key
  validates :key, inclusion: { in: KEYS }
  validates :key, uniqueness: true

  field :value

  def self.get which
    out   = where( key: which ).first&.value
    out ||= Object.const_defined?(which) && Object.const_get(which)
    out ||= ENV[which]
  end

end
