
require 'rails'
require 'byebug'

File.open('/tmp/this', 'a') { |f| f.puts "#{Time.now} - load railtie" }

module IshModels
  class Railtie < Rails::Railtie

    config.ish_models = ActiveSupport::OrderedOptions.new

    initializer "ish_models.configure" do |app|
      File.open('/tmp/this', 'a') { |f| f.puts "#{Time.now} - in railtie of ish_models" }

      IshModels.configure do |config|
        File.open('/tmp/this', 'a') { |f| f.puts "#{Time.now} - inside IshModels.configure inside... railtie" }

        require Rails.root.join("config/initializers/00_s3.rb")
        
        config.s3_cretendials = ::S3_CREDENTIALS
      end

      require Rails.root.join("config/initializers/00_s3.rb")
    end
  end
end

