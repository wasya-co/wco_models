
class ::Ish::EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  validates_uniqueness_of :slug
  validates_presence_of   :slug

  field :preview_str, type: :string

  field :layout, type: :string, default: 'plain'
  LAYOUTS = %w| plain
    m20221201react m20221222merryxmas
    m202309_feedback
    m202309_ror4
    marketing_node_1
    marketing_react_1 marketing_react_2 marketing_react_3
    marketing_ror_1 marketing_ror_2
    marketing_wordpres_1 marketing_wordpress_2
    piousbox_roundborders
    plain
    tracking_footer
    wasyaco_roundborders |

  field :subject
  field :body
  field :can_unsubscribe, type: :boolean, default: true
  field :config_exe,                      default: ""      ## unused! _vp_ 2023-09-24
  field :config_json,     type: Object,   default: '{}'

  DEFAULT_FROM_EMAIL = 'Victor Pudeyev <victor@wasya.co>'
  FROM_EMAILS = [
    'Annesque Studio <hello@annesque.studio>',
    'Annesque Studio <no-reply@annesque.studio>',

    'BJJCollective <hello@bjjcollective.com>',
    'BJJCollective <no-reply@bjjcollective.com>',

    'DemmiTV <hello@demmi.tv>',
    'DemmiTV <no-reply@demmi.tv>',

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
  field :from_email
  def self.from_email_list
    [ [nil, nil] ] + FROM_EMAILS.map { |i| [i, i] }
  end

  SIGNATURE = <<~AOL
    <div>
    <div><br></div>
    <div>Regards,</div>
    <div>-=----- &gt;8 --</div>
    <div>Victor Pudeyev<br>Director of Engineering<br><a href="mailto:victor@piousbox.com" target="_blank">victor@piousbox.com</a> | <a href="https://tidycal.com/wasya-co/30min" target="_blank">Book a chat</a><br></div>
    </div><hr /><br /><br /><br />
  AOL

  ## 2023-03-04 _vp_ This works!
  def get_binding
    @lead = Lead.where( email: 'stub@wasya.co' ).first
    binding()
  end

  has_many :email_actions,  class_name: '::Office::EmailAction'
  has_many :email_contexts, class_name: '::Ish::EmailContext'
  has_many :email_filters,  class_name: '::Office::EmailFilter',   inverse_of: :email_template
  has_many :unsubscribes,   class_name: '::Ish::EmailUnsubscribe', inverse_of: :template

  SLUG_BLANK = 'blank'
  def self.blank_template
    out = Tmpl.find_or_create_by({ slug: SLUG_BLANK })
  end
  def self.blank; self.blank_template; end

  def to_s
    "Tmpl:#{slug}"
  end

end
::Tmpl = ::Ish::EmailTemplate
