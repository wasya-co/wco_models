require 'ruby-web-search'

def puts! a, b=''
    puts "+++ #{b}"
    puts a.inspect
end

module Ish
  class Crawler

    def self.google_first_result text
      puts! text, 'text for google'
      response = RubyWebSearch::Google.search( :query => text )
      return response.results[0][:content]
    end

    def self.look_for_emails text
      puts! text, 'text for email'
    end

  end
end
