

class Ish::CacheKey
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :cities,         :type => Time # /api/cities.json
  field :feature_cities, :type => Time # /api/cities/features.json

  def self.one
    Ish::CacheKey.first || Ish::CacheKey.new
  end
end

