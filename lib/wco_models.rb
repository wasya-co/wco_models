
require 'haml'

## Fix for:
## wco_hosting_rb/test/dummy/app/models/user.rb:3:in `<class:User>': uninitialized constant User::Mongoid (NameError)
require 'mongoid'

require 'stripe'

require "wco/engine"

module Wco; end
module WcoEmail; end
module WcoHosting; end


