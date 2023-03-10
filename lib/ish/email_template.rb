
class ::Ish::EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  validates_uniqueness_of :slug
  validates_presence_of :slug

  field :preview_str, type: :string

  field :layout, type: :string, default: 'plain'
  LAYOUTS = %w| plain
    m20221201react m20221222merryxmas
    marketing_react_1
    marketing_ror_1 marketing_ror_2
    marketing_wordpres_1 marketing_wordpress_2
    piousbox_roundborders
    plain
    wasyaco_roundborders |

  field :subject
  field :body
  field :from_email

  ## 2023-03-04 _vp_ This works!
  def get_binding
    @lead = Lead.where( email: 'stub@wasya.co' ).first
    binding()
  end

  has_many :email_actions, class_name: '::Office::EmailAction'
  has_many :email_contexts, class_name: '::Ish::EmailContext'

end
::Tmpl = ::Ish::EmailTemplate
