require 'rails'

module Ish
  class Railtie < Rails::Railtie
    initializer "ish_models.configure" do |app|
    end
  end
end
