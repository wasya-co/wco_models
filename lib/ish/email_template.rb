
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
    marketing_react_1 marketing_react_2
    marketing_ror_1 marketing_ror_2
    marketing_wordpres_1 marketing_wordpress_2
    piousbox_roundborders
    plain
    wasyaco_roundborders |

  field :subject
  field :body

  FROM_EMAILS = [
    'Infinite Shelter <hello@infiniteshelter.com>',
    'Infinite Shelter <no-reply@infiniteshelter.com>',
    'Victor Piousbox <piousbox@gmail.com>',
    'Victor Piousbox <victor@piousbox.com>',
    'Victor Piousbox <no-reply@piousbox.com>',
    'Victor Piousbox <admin@wasya.co>',
    'WasyaCo Consulting <hello@wasya.co>',
    'WasyaCo Consulting <no-reply@wasya.co>',
    'Victor Piousbox <victor@wasya.co>',
  ];
  field :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  ## 2023-03-04 _vp_ This works!
  def get_binding
    @lead = Lead.where( email: 'stub@wasya.co' ).first
    binding()
  end

  has_many :email_actions, class_name: '::Office::EmailAction'
  has_many :email_contexts, class_name: '::Ish::EmailContext'

  SLUG_BLANK = 'blank'
  def self.blank_template
    out = Tmpl.find_or_create_by({ slug: SLUG_BLANK })
  end

end
::Tmpl = ::Ish::EmailTemplate
