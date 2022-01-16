
Gem::Specification.new do |s|
  s.name        = 'ish_models'
  s.version     = '0.0.33.146'
  s.date        = '2017-05-10'
  s.summary     = 'models of ish'
  s.description = 'models of ish'
  s.authors     = [ 'piousbox' ]
  s.email       = 'victor@wasya.co'
  s.files       = Dir[ "lib/*", "lib/**/*" ]
  s.homepage    = 'http://wasya.co'
  s.license     = 'MIT'

  s.add_runtime_dependency 'mongoid', '~> 7.0.5'
  s.add_runtime_dependency 'mongoid-autoinc', '~> 6.0'
  s.add_runtime_dependency 'mongoid-paperclip'
  s.add_runtime_dependency 'kaminari-mongoid', '~> 1.0.1'
  s.add_runtime_dependency 'devise', '> 0'
  s.add_runtime_dependency 'aws-sdk'

end
