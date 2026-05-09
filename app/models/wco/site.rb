
class Wco::Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
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
  has_many :tags, class_name: 'Wco::Tag'

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
    # origin
  end

  def self.list
    [[nil,nil]] + all.map { |s| [ s.slug, s.id ] }
  end

  def body
    {
      "_links": {
        "type":{"href":"http://pi.local/rest/type/node/article"}
      },
      "title":[{"value":"Node +++ 123 bac +++" }],
      "body":[{"value": "<b>hello, wor</b>ld!", "format": "full_html" }],
      "type":[{"target_id":"article"}],
      "status": [{"value": 1}],
      "_embedded": {
        "http://pi.local/rest/relation/node/article/field_issue": [
          { "uuid": [{ "value": "56229a95-d675-43e1-99b1-f9e11b5579c5" }] }
        ],
        "http://pi.local/rest/relation/node/article/field_tags": [
          { "uuid": [{ "value": "45646a7d-1a16-42e8-b758-f6e1c8d976f7" }] },
          { "uuid": [{ "value": "834e34e2-05ae-498d-b876-453798872ce1" }] }
        ]
      }

    }
  end

  def do_post
    HTTParty.post( post_url,
      body: JSON.generate( body ),
      headers: { 'Content-Type' => 'application/hal+json' },
      basic_auth: { username: username, password: password },
    )
  end

  def wp_import
    site = self

    root_tag = Wco::Tag.find_or_create_by slug: "#{site.slug}_wp-import", site_id: site.id
    url      = "#{site.origin}/wp-json/wp/v2/posts"
    pi_admin = Wco::Profile.find_or_create_by email: 'admin@piousbox.com'
    n_pages  = 12
    per_page = 100

    (1..n_pages).each do |page|
      print "Page #{page}"

      posts = HTTParty.get url, query: { per_page: per_page, page: page }
      posts.each do |post|
        report = Wco::Report.new({
          legacy_id: post['id'],
          created_at: post['date'],
          slug: post['link'].sub(site.origin, ''),
          title: post['title']['rendered'],
          subtitle: post['excerpt']['rendered'],
          body: post['content']['rendered'],
          author: pi_admin,
          tag_ids: ( [ root_tag ] + site.tags.where( :legacy_id.in => post['categories'] ) ).map(&:id),
        })

        if report.save
          print '^'
        else
          puts report.errors.messages
        end
      end
    end
    puts "ok"
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
