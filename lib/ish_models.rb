
require 'ish/railtie' if defined?(Rails)
require 'ish/configuration'
require 'aws-sdk-s3'
require 'kaminari/mongoid'

::S3_CREDENTIALS ||= {}

class Gameui; end

# module Iro; end
class Ish::InputError < RuntimeError; end
module Ish; end

# I need this thing for permissions???
class Manager; end

module Office; end

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

require 'mongoid/votable'
require 'mongoid/voter'

require 'gameui/asset3d'
require 'gameui/map'
require 'gameui/map_bookmark'
require 'gameui/marker'
require 'gameui/premium_purchase'

# require 'iro/option_price_item'

require 'ish/cache_key'
require 'ish/crawler'
require 'ish/email_campaign'
require 'ish/email_context'
require 'ish/email_template'
require 'ish/email_unsubscribe'
require 'ish/gallery_name'
require 'ish/image_asset'
require 'ish/invoice'
require 'ish/lorem_ipsum'
require 'ish/meeting'
require 'ish/payment'
require 'ish/premium_item'
require 'ish/user_profile'

require 'gallery'
require 'newsitem'
require 'photo'
require 'report'
require 'video'

require 'office/email_action'
require 'office/email_conversation'
require 'office/email_filter'
require 'office/email_message'
require 'office/email_message_stub'
require 'office/scheduled_email_action'





