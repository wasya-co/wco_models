require 'rubygems'
require 'mongoid'
require 'mongoid-paperclip'
require 'factory_bot'
require 'byebug'
require 'mongoid-rspec'
require 'database_cleaner-mongoid'
require_relative '../lib/ish_models.rb'

Mongoid.load!("config/mongoid.yml", :test)

DatabaseCleaner.clean

class User
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  field :email
  field :password
end

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.include Mongoid::Matchers, type: :model
  config.include Mongoid::Matchers
end

def do_setup
  User.unscoped.destroy
  Ish::UserProfile.unscoped.destroy
  @user_profile = FactoryBot.create :user_profile, :user => User.new, :name => 'some-name'

  # C
  City.unscoped.destroy_all
  @city = FactoryBot.create :city

  # V
  Venue.unscoped.destroy_all
end

