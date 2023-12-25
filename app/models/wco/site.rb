
class Wco::Site
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_sites'

  KIND_DRUPAL = 'drupal'
  KIND_IG     = 'instagram'
  KIND_WP     = 'wordpress'
  field :kind, type: :string

  has_many :daily_publishers, class_name: 'Wco::DailyPublisher'

  field :origin # http://pi.local
  field :post_url # http://pi.local/node?_format=hal_json

end
