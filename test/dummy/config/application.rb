
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.active_job.queue_adapter = :sidekiq
    config.time_zone = 'Central Time (US & Canada)'
  end
end

def puts! a, b=''
  puts "+++ +++ #{b}:"
  puts a.inspect
end

DEBUG ||= true
