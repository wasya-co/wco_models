
Gem::Specification.new do |s|
  s.name        = 'ish_models'
  s.version     = '0.0.33.169'
  s.date        = '2017-05-10'
  s.summary     = 'models of ish'
  s.description = 'models of ish'
  s.authors     = [ 'piousbox' ]
  s.email       = 'victor@wasya.co'
  s.files       = Dir[ "lib/*", "lib/**/*" ]
  s.homepage    = 'https://wasya.co'
  s.license     = 'Proprietary'

  s.add_runtime_dependency 'mongoid', '~> 7.3.0'
  s.add_runtime_dependency 'mongoid_paranoia'
  s.add_runtime_dependency 'mongoid-autoinc', '~> 6.0'
  s.add_runtime_dependency 'mongoid-paperclip'
  s.add_runtime_dependency 'kaminari-mongoid', '~> 1.0.1'
  s.add_runtime_dependency 'devise', '> 0'
  s.add_runtime_dependency 'aws-sdk'

end
