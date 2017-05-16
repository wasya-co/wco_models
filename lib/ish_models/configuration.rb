
module IshModels
  class Configuration
    attr_accessor :s3_credentials

    def initialize
      # @s3_credentials ||= { :bucket => '' }
    end

  end
end
