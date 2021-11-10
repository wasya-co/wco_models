
require 'ish/railtie' if defined?(Rails)
require 'ish/configuration'

::S3_CREDENTIALS ||= {}

module CoTailors; end
class Gameui; end
module Ish; end
# I need this thing for permissions#
class Manager; end

module IshModels

  class << self
    attr_accessor :configuration
  end

  def self.configure
    @configuration ||= Configuration.new
  end

  def self.setup
    yield(configuration)
  end
end

# require 'co_tailors'
# require 'co_tailors/product.rb'
# require 'co_tailors/profile_measurement.rb'
# require 'co_tailors/order.rb'
# require 'co_tailors/order_item.rb' # this is required from within order.rb
# require 'co_tailors/address.rb'

require 'gameui/map.rb'
require 'gameui/map_bookmark.rb'
require 'gameui/marker.rb'
require 'gameui/premium_purchase.rb'

# require 'ish/cache_key.rb' # this is really obsolete? _vp_ 20180123
# require 'ish/campaign.rb'
# require 'app_model2.rb'

require 'ish/crawler.rb'
require 'ish/gallery_name.rb'
require 'ish/image_asset.rb'
require 'ish/input_error.rb'
require 'ish/invoice.rb'
require 'ish/issue.rb'
require 'ish/lead.rb'
require 'ish/payment.rb'
require 'ish/premium_item.rb'
require 'ish/utils.rb'
require 'ish/user_profile.rb'

require 'aux_model.rb'
require 'city.rb'
require 'cities_user.rb'
require 'country.rb'
require 'event.rb'
require 'feature.rb'
require 'gallery.rb'
require 'newsitem.rb'
require 'photo.rb'
require 'report.rb'
require 'site.rb'
require 'tag.rb'
require 'venue.rb'
require 'video.rb'

## warbler
# require 'ish/alphavantage_stockwatcher.rb'
# require 'ish/ameritrade'
# require 'ish/covered_call'
# require 'ish/iron_condor.rb'
# require 'ish/iron_condor_watcher.rb'
# require 'ish/stock_action.rb'
# require 'ish/stock_option.rb'
# require 'ish/stock_watch.rb'
# require 'ish/yahoo_stockwatcher.rb'




