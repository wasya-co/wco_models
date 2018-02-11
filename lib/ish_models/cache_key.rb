
module IshModels
  class CacheKey
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    field :cities,         :type => Time # /api/cities.json
    field :feature_cities, :type => Time # /api/cities/features.json

    def self.one
      IshModels::CacheKey.first || IshModels::CacheKey.new
    end
  end
end
