class Gallery < AppModel2

  belongs_to :site
  validates :site, :presence => true

  belongs_to :user
  validates :user, :presence => true
  field :username, :type => String
  
  field :name, :type => String
  validates :name, :uniqueness => true # , :allow_nil => false

  field :galleryname, :type => String
  validates :galleryname, :uniqueness => true # , :allow_nil => false

  field :subhead, :type => String
  field :descr, :type => String
  field :lang, :type => String, :default => 'en'

  # not necessary because AppModel2
  # default_scope ->{ where( :is_public => true, :is_trash => false ).order_by( :created_at => :desc ) }

  has_many :photos

  belongs_to :tag
  belongs_to :city
  belongs_to :venue
    
  set_callback(:create, :before) do |doc|
    doc.username = doc.user.username
    doc.galleryname = doc.name.to_simple_string

    # for the homepage
    if doc.is_public && doc.site
      n = Newsitem.new {}
      n.gallery = doc
      n.username = doc.user.username
      sites = Site.where( :domain => doc.site.domain )
      sites.each do |site|
        site.newsitems << n
        flag = site.save
        if !flag
          puts! site.errors
        end
      end
    end
  end

  # @deprecated, use Gallery::ACTIONS
  def self.actions
    [ 'show_mini', 'show_long', 'show' ]
  end
  ACTIONS = [ 'show_mini', 'show_long', 'show' ]

end

