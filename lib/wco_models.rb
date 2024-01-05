
require 'aws-sdk-s3'


require 'cancancan'
require 'devise'
require 'haml'
require 'httparty'

require 'mail'
require 'mongoid'
require 'mongoid_paranoia'

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
