
Gem::Specification.new do |spec|
  spec.name        = "ish_models"
  spec.version     = "3.1.0.15"
  spec.authors     = ["mac_a2141"]
  spec.email       = ["victor@piousbox.com"]
  spec.homepage    = "https://wasya.co"
  spec.summary     = "https://wasya.co"
  spec.description = "https://wasya.co"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://wasya.co"
  spec.metadata["changelog_uri"] = "https://wasya.co"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.0"
  spec.add_dependency 'mongoid', '~> 7.3.0'
  spec.add_dependency 'mongoid_paranoia'
  spec.add_dependency 'mongoid-autoinc', '~> 6.0'
  spec.add_dependency 'mongoid-paperclip'
  spec.add_dependency 'kaminari-mongoid', '~> 1.0.1'

  spec.add_dependency 'net-ssh', "~> 7.2.0"
  spec.add_dependency 'net-scp', "~> 4.0.0"

end
