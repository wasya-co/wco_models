
def url_exists?(url)
  response = HTTParty.head(url, timeout: 5, follow_redirects: true)
  response.code == 200
rescue StandardError
  false
end

class Wco::Publisher
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_publishers'

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

    return true
  end


  def to_s
    "#{site} :: #{slug}"
  end

  def self.list
    [[nil,nil]] + all.map { |p| [p, p.id] }
  end
end

=begin

curl --include \
  --request POST \
  --user admin:<>, \
  --header 'Content-type: application/hal+json' \
  http://pi.local/node?_format=hal_json \
  --data-binary '{
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
  }'

=end
