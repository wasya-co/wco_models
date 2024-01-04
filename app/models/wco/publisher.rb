
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

  def to_s
    "#{slug}: #{kind} => #{site}"
  end

  field :context_eval
  field :after_eval
  field :post_body_tmpl

  has_many :oats, class_name: 'Wco::OfficeActionTemplate'


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
