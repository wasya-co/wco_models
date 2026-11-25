
class Wco::Site
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_sites'

  KIND_DRUPAL = 'drupal'
  KIND_IG     = 'instagram'
  KIND_WP     = 'wordpress'
  KINDS       = %w| drupal instagram wordpress |
  field :kind, type: :string
  def self.kinds_list
    [nil] + KINDS
  end


  has_many :headlines # , class_name: 'Wco::Newstitle'
  has_many :logs, inverse_of: :obj
  has_many :publishers # , class_name: 'Wco::Publisher'
  has_many :sitemap_paths, class_name: 'Wco::SitemapPath'
  has_many :tags, class_name: 'Wco::Tag', inverse_of: :site

  field :slug
  validates :slug, presence: true, uniqueness: true

  field :origin # http://pi.local
  # validates :origin, presence: true, uniqueness: true

  field :post_path # /node?_format=hal_json
  field :username
  field :password

  default_scope ->{ order_by( slug: :asc ) }

  def to_s
    slug
  end

  def self.list
    [[nil,nil]] + all.map { |s| [ s.slug, s.id ] }
  end

  def check_sitemap
    @results = []
    @total_count = 0
    @error_count = 0

    sitemap_paths.each do |check|
      @total_count += 1

      puts "Checking #{check[:path]}:"
      if check[:selector].present?
        begin
          body = HTTParty.get( "#{origin}#{check[:path]}" ).body
        rescue OpenSSL::SSL::SSLError => err
          @results.push "NOT OK [ssl-exception] #{check[:path]}".red
          logg "NOT OK [ssl-exception] #{check[:path]}"
          check.update status: 'NOT OK'

          next
        end
        doc = Nokogiri::HTML( body )
        out = doc.search check[:selector]
        if out.present?
          @results.push "OK #{check[:path]}"
          logg "OK #{check[:path]}"
          check.update status: 'OK'
        else
          @results.push "NOT OK [selector-missing] #{check[:path]}".red
          logg "NOT OK [selector-missing] #{check[:path]}"
          check.update status: 'NOT OK'
          @error_count += 1
        end

        if check[:meta_description]
          out = doc.search( 'head meta[name="description"]' )[0]['content']
          if check[:meta_description] == out
            @results.push "OK #{check[:path]} meta_description"
            logg "OK #{check[:path]} meta_description"
            check.update status: 'OK'
          else
            @results.push "NOT OK [meta-description-missing] #{check[:path]}".red
            logg "NOT OK [meta-description-missing] #{check[:path]}"
            check.update status: 'NOT OK'
            @error_count += 1
          end
        end

      elsif check[:redirect_to].present?
        out = HTTParty.get( "#{origin}#{check[:path]}", follow_redirects: false )
        if( out.headers[:location] == check[:redirect_to] ||
            out.headers[:location] == "#{origin}#{check[:redirect_to]}" )
          @results.push "OK #{check[:path]}"
          logg "OK #{check[:path]}"
          check.update status: 'OK'
        else
          @results.push "NOT OK [redirect-missing] #{check[:path]}".red
          logg "NOT OK [redirect-missing] #{check[:path]}"
          check.update status: 'NOT OK'

          puts!( out.response, 'response' ) if DEBUG
          # puts!( out.body, 'body' ) if DEBUG

          @error_count += 1

          puts "NOT OK #{check[:path]}".red
          puts out.headers[:location]
          puts check[:redirect_to]
        end
      else
        @results.push "SKIP #{check[:path]}"
        logg "SKIP #{check[:path]}"
        check.update status: 'SKIP'
      end

      if check[:selectors]&[0]
        check[:selectors].each do |selector|
          body = HTTParty.get( "#{origin}#{check[:path]}" ).body
          doc = Nokogiri::HTML( body )
          out = doc.search selector
          if out.present?
            @results.push "OK #{check[:path]} selectors:#{selector}"
            logg "OK #{check[:path]} selectors:#{selector}"
            check.update status: 'OK'
          else
            @results.push "NOT OK [selectors-missing:#{selector}] #{check[:path]}".red
            logg "NOT OK [selectors-missing:#{selector}] #{check[:path]}"
            check.update status: 'NOT OK'
            @error_count += 1
          end
        end
      end

    end

    puts "Results:".green
    @results.each do |r|
      puts r
    end
    puts "Total count: #{@total_count}"
    puts "Error count: #{@error_count}"
    return { total_count: @total_count, error_count: @error_count, results: @results }
  end

  def logg msg
    Wco::Log.create!({
      message: msg,
      obj: self,
    })
  end

end
