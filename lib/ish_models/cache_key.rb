
module IshModels
  class CacheKey
    include ::Mongoid::Document
    include ::Mongoid::Timestamps

    ## /api/cities.json
    field :cities, :type => Time 

    def self.one
      IshModels::CacheKey.first || IshModels::CacheKey.new
    end
  end
end
