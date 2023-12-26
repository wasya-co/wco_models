
##
## Edit the template!
##
Gem::Specification.new do |spec|
  spec.name        = "wco_models"
  spec.version     = "3.1.0.30"
  spec.authors     = [ "Victor Pudeyev"  ]
  spec.email       = [ "victor@wasya.co" ]
  spec.homepage    = "https://wasya.co"
  spec.summary     = "https://wasya.co"
  spec.description = "https://wasya.co"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://wasya.co"
  spec.metadata["changelog_uri"]   = "https://wasya.co"

  spec.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.txt"]

  ##
  ## Edit the template!
  ##
  spec.add_dependency "rails", "~> 6.1.0"

  spec.add_dependency 'mongoid',          '~> 7.3.0'
  spec.add_dependency 'mongoid_paranoia'
  spec.add_dependency 'mongoid-autoinc',  '~> 6.0'
  spec.add_dependency 'mongoid-paperclip'
  spec.add_dependency 'kaminari-mongoid', '~> 1.0.1'

  spec.add_dependency 'aws-sdk-s3'

  spec.add_dependency 'net-ssh',     "~> 7.2.0"
  spec.add_dependency 'net-scp',     "~> 4.0.0"
  spec.add_dependency 'droplet_kit', "~> 3.20.0"

  spec.add_dependency 'stripe',      "~> 10.4.0"

end
