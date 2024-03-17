
DEFAULT_FROM_EMAIL = 'no-reply@wasya.co'

class WcoEmail::EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_email_templates'

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ slug: 1 }, { unique: true, name: "slug_idx" })
  def to_s
    "Tmpl:#{slug}"
  end

  field :preview_str, type: :string

  field :layout, type: :string, default: 'plain'
  LAYOUTS = %w| plain
    m20221201react m20221222merryxmas
    m202309_feedback
    m202309_ror4
    marketing_node_1
    marketing_react_1
    marketing_react_2
    marketing_react_3
    marketing_ror_1
    marketing_ror_2
    marketing_wordpres_1
    marketing_wordpress_2
    piousbox_roundborders
    plain
    test_tracking_footer
    wasyaco_roundborders |

  field :subject
  field :body
  field :can_unsubscribe, type: :boolean, default: true
  field :config_exe,                      default: ""      ## unused! _vp_ 2023-09-24
  field :config_json,     type: Object,   default: '{}'
  field :layout, default: 'plain'
  field :mangle_subject, type: :boolean, default: false

  DEFAULT_FROM_EMAIL = 'Victor Pudeyev <no-reply@wasya.co>'
  FROM_EMAILS = [
    'Annesque Studio <hello@annesque.studio>',
    'Annesque Studio <no-reply@annesque.studio>',

    'BJJCollective <hello@bjjcollective.com>',
    'BJJCollective <no-reply@bjjcollective.com>',

    'DemmiTV <hello@demmi.tv>',
    'DemmiTV <no-reply@demmi.tv>',

    'Victor Pudeyev <victor@fedfis.com>',

    'Infinite Shelter <hello@infiniteshelter.com>',
    'Infinite Shelter <no-reply@infiniteshelter.com>',

    'Oquaney Splicing <hello@oquaney-splicing.com>',
    'Oquaney Splicing <no-reply@oquaney-splicing.com>',

    'Victor Pudeyev <piousbox@gmail.com>',
    'Victor Pudeyev <victor@piousbox.com>',
    'Victor Pudeyev <no-reply@piousbox.com>',
    'Victor Pudeyev <victor@pudeyev.com>',

    'Sender SBS <hello@sender.sbs>',
    'Sender SBS <no-reply@sender.sbs>',

    'WasyaCo Consulting <admin@wasya.co>',
    'Alex WCo <alex@wasya.co>',
    'Bailey WCo <bailey@wasya.co>',
    'Cameron WCo <cameron@wasya.co>',
    'WasyaCo Consulting <hello@wasya.co>',
    'Jess WCo <jess@wasya.co>',
    'WasyaCo Consulting <no-reply@wasya.co>',
    'Victor Pudeyev <victor@wasya.co>',

    'WasyaCo Consulting <admin@wasyaco.com>',
    'Alex WCo <alex@wasyaco.com>',
    'Bailey WCo <bailey@wasyaco.com>',
    'Cameron WCo <cameron@wasyaco.com>',
    'WasyaCo Consulting <hello@wasyaco.com>',
    'WasyaCo Consulting <no-reply@wasyaco.com>',
    'Victor Pudeyev <victor@wasyaco.com>',

    'Wasya Co Mailer <no-reply@wco.com.de>',
    'Wasya Co Mailer <wasyacomailer@gmail.com>',
  ];
  FROM_EMAILS_2 = [
    [ nil, nil ],

    [ 'Victor Pudeyev <piousbox@gmail.com>',    'piousbox@gmail.com' ],
    [ 'Victor Pudeyev <victor@piousbox.com>',   'victor@piousbox.com' ],
    [ 'Victor Pudeyev <no-reply@piousbox.com>', 'no-reply@piousbox.com' ],

    [ 'WasyaCo Consulting <no-reply@wasya.co>', 'no-reply@wasya.co' ],
    [ 'Victor Pudeyev <victor@wasya.co>',       'victor@wasya.co' ],

  ];
  field :from_email
  def self.from_emails_list
    # [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
    FROM_EMAILS_2
  end

  SIGNATURE = <<~AOL
    <div>
    <div><br></div>
    <div>Regards,</div>
    <div>-=----- &gt;8 --</div>
    <div>Victor Pudeyev<br>Director of Engineering<br><a href="mailto:victor@wasya.co" target="_blank">victor@wasya.co</a> | <a href="https://tidycal.com/wasya-co/30min" target="_blank">Book a chat</a><br></div>
    </div><hr /><br /><br /><br />
  AOL

  ## 2023-03-04 _vp_ This works!
  def get_binding
    # @lead = Lead.where( email: 'stub@wasya.co' ).first
    binding()
  end

  has_many :email_actions,  class_name: '::WcoEmail::EmailAction'
  has_many :email_contexts, class_name: '::WcoEmail::Context'
  has_many :email_filters,  class_name: '::WcoEmail::EmailFilter'
  has_many :unsubscribes,   class_name: '::WcoEmail::Unsubscribe'

  SLUG_BLANK = 'blank'
  def self.blank_template
    out = Tmpl.find_or_create_by({ slug: SLUG_BLANK })
  end
  def self.blank; self.blank_template; end

  def self.list
    [[nil,nil]] + all.map { |p| [ p.slug, p.id ] }
  end
end
