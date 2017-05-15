

require 'ish_models/configuration'

module IshModels
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    yield(configuration)
  end

end

require 'app_model2.rb'
require 'aux_model.rb'
require 'city.rb'
require 'country.rb'
require 'event.rb'
require 'feature.rb'
require 'gallery.rb'
require 'newsitem.rb'
require 'photo.rb'
require 'public_item.rb'
require 'report.rb'
require 'site.rb'
require 'tag.rb'
require 'venue.rb'
require 'video.rb'
