
require_relative './spec/spec_helper'
require_relative './config/initializers/00_s3.rb'
require_relative './lib/ish_models'

namespace :db do

  desc 'seed'
  task :seed do

    Office::Emailtag.find_or_create_by!({ slug: Office::Emailtag::INBOX })
    puts 'Emailtag `inbox` exists.'
    Office::Emailtag.find_or_create_by!({ slug: Office::Emailtag::TRASH })
    puts 'Emailtag `trash` exists.'

  end

end

namespace :rspec do

  task :default => :spec

  desc 'spec default task in rake'
  task :spec do
  end

end
