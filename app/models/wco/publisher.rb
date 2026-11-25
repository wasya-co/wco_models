
def url_exists?(url)
  response = HTTParty.head(url, timeout: 5, follow_redirects: true)
  response.code == 200
rescue StandardError
  false
end

class Wco::Publisher
  include Mongoid::Document
  include Mongoid::Timestamps
  include Wco::PublisherD10
  store_in collection: 'wco_publishers'

  attr_accessor :output_str

  field :slug
  validates :slug, presence: true, uniqueness: true

  KIND_ARTICLE = 'article'
  KIND_IMAGE   = 'image'
  field :kind, type: :string

  belongs_to :site,      class_name: 'Wco::Site'

  field :context_eval
  field :after_eval
  field :post_body_tmpl
  field :post_path

  has_many :oats, class_name: 'Wco::OfficeActionTemplate'
  has_and_belongs_to_many :tags

  attr_accessor :props

  def do_run
    @publisher = publisher = self

    @site    = publisher.site
    @headers = {}
    @ctx     = OpenStruct.new

    puts! publisher.context_eval, 'context_eval'
    eval( publisher.context_eval )
    puts! @ctx, '@ctx'

    if @abort
      errors.add(:base, 'aborted')
      return false
    end

    tmpl = ERB.new publisher.post_body_tmpl
    body = JSON.parse tmpl.result(binding)
    puts! body, 'body'

    out = Wco::HTTParty.post( "#{@site.origin}#{post_path}", {
      body: body.to_json,
      headers: @headers,
      basic_auth: { username: @site.username, password: @site.password },
      debug_output: $stdout,
    })
    puts! out.response, 'publisher httparty response'
    puts! out.body,     'publisher httparty body'
    if out.code != 201
      puts! out.body, "publisher#do_run non-201 status"
      ::ExceptionNotifier.notify_exception(
        Exception.new,
        data: {
          httparty_body: out.body,
          httparty: out,
          label: "publisher#do_run non-201 status",
        } )
      raise out.body
    end

    if after_eval.present?
      puts! after_eval, 'after_eval'
      eval( after_eval )
    end

    publisher.output_str = out
    return true
  end


  def to_s
    "#{site} :: #{slug}"
  end

  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end
