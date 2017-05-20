require 'rails'
# require 'byebug'

# File.open( '/tmp/this', 'a' ) { |f| f.puts "ish_models/railtie root: #{Rails.root}" }
# require Rails.root.join("config/initializers/00_s3.rb")        

module IshModels
  class Railtie < Rails::Railtie

    # File.open( '/tmp/this', 'a' ) { |f| f.puts "ish_models/railtie config: #{config.inspect}" }
    # File.open( '/tmp/this', 'a' ) { |f| f.puts "ish_models/railtie callback root: #{Rails.root}" }

    initializer "ish_models.configure" do |app|
      # File.open( '/tmp/this', 'a' ) { |f| f.puts "ish_models/railtie callback initializer root: #{Rails.root}" }
      # require Rails.root.join("config/initializers/00_s3.rb")
    end
  end
end
