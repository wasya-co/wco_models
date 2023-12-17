
require 'mongoid'

require "ish_models/engine"

module IshModels; end
module Wco; end
module WcoEmail; end
module WcoHosting; end

require 'wco/lead'
require 'wco/leadset'
require 'wco/office_action'
require 'wco/profile'
require 'wco/tag'

require 'wco_email/campaign'
require 'wco_email/context'
require 'wco_email/conversation'
require 'wco_email/email_filter'
require 'wco_email/message_template'
require 'wco_email/scheduled_email_action'

require 'wco_hosting/appliance'
require 'wco_hosting/appliance_tmpl'
require 'wco_hosting/domain'
require 'wco_hosting/serverhost'


