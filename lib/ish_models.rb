
require 'ish/railtie' if defined?(Rails)
require 'ish/configuration'

::S3_CREDENTIALS ||= {}

class Gameui; end

module Ish; end

# I need this thing for permissions???
class Manager; end

module Warbler; end

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

## Needs to be before gameui/asset3d
require 'ish/utils'

require 'mongoid/voteable'
require 'mongoid/voter'

require 'gameui/asset3d'
require 'gameui/map'
require 'gameui/map_bookmark'
require 'gameui/marker'
require 'gameui/premium_purchase'

require 'ish/cache_key'
require 'ish/campaign'
require 'ish/crawler'
require 'ish/email_context'
require 'ish/gallery_name'
require 'ish/image_asset'
require 'ish/input_error'
require 'ish/invoice'
require 'ish/issue'
require 'ish/lead'
require 'ish/meeting'
require 'ish/payment'
require 'ish/premium_item'
require 'ish/unsubscribe'
require 'ish/user_profile'

require 'city'
require 'cities_user'
require 'country'
require 'event'
require 'feature'
require 'gallery'
require 'newsitem'
require 'photo'
require 'report'
require 'site'
require 'tag'
require 'venue'
require 'video'




