
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

# require "omniauth-keycloak"

# require 'select2-rails'
require 'sass-rails'
require 'stripe'

require "wco/engine"
require 'wco/ai_writer'

ACTIVE   = 'active'
INACTIVE = 'inactive'
STATUSES = [ nil, ACTIVE, INACTIVE ]

module Iro; end
module Tda; end
module Wco; end

module WcoEmail
  ACTION_ADD_TAG               = 'add-tag'
  ACTION_AUTORESPOND           = 'autorespond-template'
  ACTION_EXE                   = 'exe'
  ACTION_SCHEDULE_EMAIL_ACTION = 'autorespond-email-action'
  ACTION_REMOVE_EMAIL_ACTION   = 'remove-email-action'
  ACTION_REMOVE_TAG            = 'remove-tag'
  ACTIONS = [ 'add-tag', 'autorespond-email-action', 'autorespond-template', 'exe', 'remove-email-action', 'remove-tag' ]

  FIELD_BODY    = 'body'
  FIELD_EXE     = 'exe'
  FIELD_FROM    = 'from'
  FIELD_LEADSET = 'leadset_id'
  FIELD_SUBJECT = 'subject'
  FIELD_TO      = 'to'

  OPERATOR_EQUALS      = 'eq'
  OPERATOR_HAS_TAG     = 'has-tag'
  OPERATOR_NOT_HAS_TAG = 'not-has-tag'
  # OPERATOR_TEXT_INPUT  = 'text-input'
  OPERATORS = [ 'equals', 'has-tag', 'not-has-tag', 'text-input' ]
end

module WcoHosting; end

class Wco::HTTParty
  include HTTParty
  debug_output STDOUT
end

ActiveSupport.escape_html_entities_in_json = true


HEIGHT_SEC = 100.0
HEIGHT_MS = HEIGHT_SEC/1000

