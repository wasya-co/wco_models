require 'rubygems'
require 'mongoid'
require 'mongoid-paperclip'
require 'factory_bot'

Mongoid.load!("config/mongoid.yml", :test)

class User
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
end

require_relative '../lib/ish_models.rb'

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

def do_setup
  User.unscoped.destroy
  IshModels::UserProfile.unscoped.destroy
  @user_profile = FactoryBot.create :user_profile, :user => User.new, :name => 'some-name'
end
