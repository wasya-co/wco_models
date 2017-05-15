require 'rubygems'
require 'mongoid'
require 'mongoid-paperclip'

class User
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
end

require_relative '../lib/ish_models.rb'

def puts! a, b=''
  puts "+++ +++ #{b}"
  puts a.inspect
end
