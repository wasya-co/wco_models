
require 'byebug'
require 'database_cleaner-mongoid'
require 'factory_bot'
require 'mongoid'
require 'mongoid-paperclip'
require 'mongoid_paranoia'
require 'mongoid-rspec'
require 'rubygems'

require_relative '../lib/mongoid/votable.rb'
require_relative '../lib/mongoid/voter.rb'
class Post
  include ::Mongoid::Document
  include ::Mongoid::Votable
  vote_point self, :up => +1, :down => -1
  has_many :comments
end
class Comment
  include Mongoid::Document
  include Mongoid::Votable
  belongs_to :post
  vote_point self, :up => +1, :down => -3
  vote_point Post, :up => +2, :down => -1
end



def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end

Paperclip.options[:log] = false

::S3_CREDENTIALS ||= {
  :access_key_id => ENV['AWS_KEY_TRAVIS'],
  :secret_access_key => ENV['AWS_SECRET_TRAVIS'],
  :bucket => "ish-test-3",
  :region => 'us-east-1' # NOT :s3_region ?!?!
}

require_relative '../lib/ish_models.rb'

Mongoid.load!("config/mongoid.yml", :test)

DatabaseCleaner.clean

module Rails
  def self.root
    './'
  end
end

class User
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  field :email
  field :password
  has_one :profile, :class_name => '::Ish::UserProfile'
end
User.unscoped.destroy_all

## prettyprint for json (@TODO: implement)
def pputs! a, b=''
  puts "+++ +++ #{b}"
  puts a
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
  DatabaseCleaner.clean
end

