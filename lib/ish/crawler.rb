
def puts! a, b=''
    puts "+++ #{b}"
    puts a.inspect
end

module Ish
  class Crawler

    def self.google_first_result text
      result = HTTParty.get( "https://www.google.com/search?q=#{text}", :verify => false )
      r = Nokogiri::HTML(result.body)
      website = r.css('cite')[0].text
      website = "https://#{website}" unless website[0..3] == 'http'

      puts! website, 'website'

      begin
        r = HTTParty.get( website, :verify => false )
      rescue OpenSSL::SSL::SSLError => e
        puts! e, 'e'
        return { :url => website }
      end

      return { :url => website, :html => r.body }
    end

    def self.look_for_emails text
      email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
      result = text.scan( email_regex )
      return result.length > 0 ? result.join(',') : nil
    end

  end
end
