
require 'ish_models/railtie' if defined?(Rails)
require 'ish_models/configuration'

::S3_CREDENTIALS ||= {}

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

require 'co_tailors'
require 'co_tailors/product.rb'
require 'co_tailors/profile_measurement.rb'
require 'co_tailors/order.rb'
# require 'co_tailors/order_item.rb' # this is required from within order.rb
require 'co_tailors/address.rb'

require 'ish/crawler.rb'
require 'ish/gallery_name.rb'
require 'ish/payment.rb'
require 'ish/stock_action.rb'
require 'ish/stock_option.rb'
require 'ish/stock_watch.rb'
require 'ish/invoice.rb'
require 'ish/lead.rb'
require 'ish/campaign.rb'
require 'ish/issue.rb'

# obsolete, use `ish` namespace now
require 'ish_models/cache_key.rb' # this is really obsolete? _vp_ 20180123
require 'ish_models/user_profile.rb'

require 'app_model2.rb'
require 'aux_model.rb'
require 'city.rb'
require 'cities_user.rb'
require 'country.rb'
require 'event.rb'
require 'feature.rb'
require 'gallery.rb'
require 'gallery2.rb'
require 'manager.rb'
require 'newsitem.rb'
require 'photo.rb'
require 'public_item.rb'
require 'report.rb'
require 'site.rb'
require 'tag.rb'
require 'venue.rb'
require 'video.rb'








