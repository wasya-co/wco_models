
require 'httparty'
# require 'wco_models'

class Wco::ScrapeTest2

  def initialize site:
    # site = Wco::Site.find_by slug: 'wsj'
    max_count = 2

    out = HTTParty.get( site.origin ).response.body
    out = Nokogiri::HTML(out)
    out.css('h3').each_with_index do |headline, idx|
      if idx < max_count
        puts! headline.text, 'headline'
        h = Wco::Headline.create({
          date: Time.now.to_date,
          site: site,
          name: headline.text,
        })
        if h.persisted?
          print '.'
        else
          puts! h.errors.full_messages
        end
      end
    end
  end

end

