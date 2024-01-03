
require 'wco/scrape_test'
require 'wco/scrape_test_2'

namespace :db do

  desc 'seed'
  task :seed do
    leadset = Wco::Leadset.find_or_create_by({ company_url: 'poxlovi@gmail.com' })
    leadset.persisted?
    lead    = Wco::Lead.find_or_create_by({ email: 'poxlovi@gmail.com', leadset: leadset })
    lead.persisted?
  end

end

RSpec::Core::RakeTask.new(:spec)
namespace :scrape do

  desc 'test'
  task :test do
    Wco::ScrapeTest.new
  end

  desc 'test 2'
  task :test_2 do

    site = Wco::Site.find_by slug: 'wsj'
    Wco::ScrapeTest2.new( site: site )

  end

end
