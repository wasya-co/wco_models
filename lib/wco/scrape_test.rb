
# require 'capybara/rspec'
# require 'byebug'
require 'capybara/rails'

Capybara.register_driver :selenium_chrome do |app|
  # options = Selenium::WebDriver::Chrome::Options.new
  # options.add_argument '--remote-debugging-port=4444'
  # Capybara::Selenium::Driver.new(app,
  #   browser: :chrome,
  #   options: options )

  Capybara::Selenium::Driver.new app, browser: :chrome
end

Capybara.default_driver = :selenium_chrome
Capybara.default_max_wait_time = 100 # seconds
Capybara.server = :webrick

class Wco::ScrapeTest
  include Capybara::DSL

  def initialize

    visit 'https://www.wsj.com/'

    # all('h6').each_with_index do |h6, idx|
    (1...2).each do |idx|
      headline = find(:xpath, "(//h3)[#{idx}]").text
      # puts "+++ Title: #{title}"

      Wco::Headline.create!({
        name: headline,
        site: wsj,
        date: Time.now.to_date,
      })
      print '.'
    end

    # byebug
  end

end

