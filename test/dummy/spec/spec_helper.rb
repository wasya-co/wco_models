
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

  config.include Devise::TestHelpers, type: :controller
  config.include FactoryBot::Syntax::Methods

end

def destroy_every *args
  args.each do |arg|
    arg.unscoped.map &:destroy!
  end
end

def setup_users

  User.all.destroy_all
  user = User.create!( email: 'victor@wasya.co', password: 'test1234', provider: 'keycloakopenid' )
  Wco::Profile.unscoped.map &:destroy!
  p = Wco::Profile.create!( email: user.email )
  sign_in user

end

