
require 'aws-sdk-s3'

require 'business_time'

require 'cancancan'

require 'devise'

require 'haml'
require 'httparty'

require 'kaminari/mongoid'
require 'kaminari/actionview'

require 'mail'
require 'mongoid'
require 'mongoid_paranoia'

require "omniauth-keycloak"

# require 'select2-rails'
require 'sass-rails'
require 'stripe'

require "wco/engine"

ACTIVE   = 'active'
INACTIVE = 'inactive'
STATUSES = [ nil, ACTIVE, INACTIVE ]

module Wco; end
module WcoEmail; end
module WcoHosting; end

class Wco::HTTParty
  include HTTParty
  debug_output STDOUT
end

ActiveSupport.escape_html_entities_in_json = true
