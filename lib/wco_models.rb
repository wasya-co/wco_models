
require 'cancancan'
require 'devise'
require 'haml'
require 'httparty'

## Fix for:
## wco_hosting_rb/test/dummy/app/models/user.rb:3:in `<class:User>': uninitialized constant User::Mongoid (NameError)
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
