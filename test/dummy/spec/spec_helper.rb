
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

## See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods

end

class EmailDeliveryObserver
  def self.delivered_email(message)
    puts! message, 'EmailDeliveryObserver'
  end
end

def destroy_every *args
  args.each do |arg|
    arg.unscoped.map &:destroy!
  end
end

def setup_users
  Wco::Leadset.unscoped.map &:destroy!
  leadset = Wco::Leadset.create!( company_url: 'test' )

  User.all.destroy_all
  user        = User.create!( email: 'victor@wasya.co', password: 'test1234', provider: 'keycloakopenid' )

  Wco::Profile.unscoped.map &:destroy!
  profile        = Wco::Profile.create!( email: user.email, leadset: leadset )

  sign_in user
end

Wco::Obf = Wco::ObfuscatedRedirect

EPSILON = 0.0001
