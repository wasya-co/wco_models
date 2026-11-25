
class Wco::SitemapPath
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_sitemap_paths'

  belongs_to :site, class_name: 'Wco::Site'

  field :path,        type: String
  validates :path, presence: true, uniqueness: { scope: :site }

  field :meta_description, type: String
  field :redirect_to, type: String
  field :selector,    type: String
  field :selectors,   type: Array, default: []
  field :title,       type: String


  field :status,  type: String

  # field :results, type: Array, default: []
  has_many :logs, inverse_of: :obj
  def results
    logs.map { |log| "#{log.message} [on #{log.created_at.to_s[0...10]}]" }
  end

  def check
    self.status = 'NOT_OK'
    skip_rest = false

    if self[:selector].present?
      begin
        body = HTTParty.get( "#{site.origin}#{self[:path]}" ).body
      rescue OpenSSL::SSL::SSLError => err
        log = Wco::Log.create obj: self, message:  "NOT OK [ssl-exception] #{self[:path]}" # .red
        return
      end
      doc = Nokogiri::HTML( body )
      out = doc.search self[:selector]
      if out.present?
        log = Wco::Log.create obj: self, message:  "OK #{self[:path]}"
        self.status = 'OK'
      else
        log = Wco::Log.create obj: self, message:  "NOT OK [selector-missing] #{self[:path]}" # .red
      end

    elsif self[:redirect_to].present?
      out = HTTParty.get( "#{site.origin}#{self[:path]}", follow_redirects: false )
      if( out.headers[:location] == self[:redirect_to] ||
          out.headers[:location] == "#{site.origin}#{self[:redirect_to]}" )
        log = Wco::Log.create obj: self, message:  "OK #{self[:path]}"
        self.status = 'OK'
      else
        log = Wco::Log.create obj: self, message:  "NOT OK [redirect-missing] #{self[:path]}" # .red

        puts!( out.response, 'response' ) if DEBUG
        # puts!( out.body, 'body' ) if DEBUG

        puts "NOT OK #{self[:path]}" # .red
        puts out.headers[:location]
        puts self[:redirect_to]
      end
      skip_rest = true
    else
      log = Wco::Log.create obj: self, message:  "SKIP #{self[:path]}"
      self.status = 'OK'
      skip_rest = true
    end

    if !skip_rest

      if self[:meta_description].present?
        out = doc.search( 'head meta[name="description"]' )[0]['content']
        if out.include?( self[:meta_description] )
          log = Wco::Log.create obj: self, message:  "OK #{self[:path]} meta_description"
        else
          self.status = 'NOT_OK'
          log = Wco::Log.create obj: self, message:  "NOT OK [meta-description-no-contain] #{self[:path]}" # .red
        end
      end

      if self[:selectors].present?
        self[:selectors].each do |selector|
          out = doc.search selector
          if out.present?
            log = Wco::Log.create obj: self, message:  "OK #{self[:path]} selectors:#{selector}"
          else
            self.status = 'NOT_OK'
            log = Wco::Log.create obj: self, message:  "NOT OK [selectors-missing:#{selector}] #{self[:path]}" # .red
          end
        end
      end

      if self[:title].present?
        out = doc.search( 'head title' )[0].text
        if out.include?( self[:title] )
          log = Wco::Log.create obj: self, message:  "OK #{self[:path]} title"
        else
          self.status = 'NOT_OK'
          log = Wco::Log.create obj: self, message:  "NOT OK [title-no-contain] #{self[:path]}" # .red
        end
      end

    end

    self.save
  end

end

