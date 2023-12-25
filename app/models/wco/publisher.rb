
class Wco::Publisher
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_daily_publishers'

  KIND_ARTICLE = 'article'
  KIND_IMAGE   = 'image'
  field :kind, type: :string

  belongs_to :to_site,      class_name: 'Wco::Site'
  belongs_to :from_gallery, class_name: 'Wco::Gallery'

  field :title_eval, type: :string ## "#{Time.now.strftime('%Y-%m-%d') Daily Tree}" with the quotes



end
