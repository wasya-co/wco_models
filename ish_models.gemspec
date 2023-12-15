
Gem::Specification.new do |spec|
  spec.name        = 'ish_models'
  spec.version     = '3.0.0.1'
  spec.date        = '2017-05-10'
  spec.summary     = 'models of ish'
  spec.description = 'models of ish'
  spec.authors     = [ 'piousbox' ]
  spec.email       = 'victor@wasya.co'
  spec.files       = Dir[ "lib/*", "lib/**/*" ]
  spec.homepage    = 'https://wasya.co'
  spec.license     = 'Proprietary'

  ##
  ## edit the template, not the gemspec!
  ##
  spec.add_dependency 'mongoid', '~> 7.3.0'
  spec.add_dependency 'mongoid_paranoia'
  spec.add_dependency 'mongoid-autoinc', '~> 6.0'
  spec.add_dependency 'mongoid-paperclip'
  spec.add_dependency 'kaminari-mongoid', '~> 1.0.1'
  spec.add_dependency 'devise', '> 0'
  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'rails', '~> 6.1.0' ## only for ActionView in email_message model. _vp_ 2023-03-27
  spec.add_dependency 'net-ssh', '~> 7.1.0'
  spec.add_dependency 'prawn', '~> 2.4.0'
  spec.add_dependency 'prawn-table', '~> 0.2.1'
  spec.add_dependency 'net-scp', '~> 4.0.0'

end
