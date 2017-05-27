class Gallery < AppModel2

  belongs_to :site
  validates :site, :presence => true

  belongs_to :user,         :optional => true
  belongs_to :user_profile, :optional => true, :class_name => 'IshModels::UserProfile'
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

  belongs_to :tag, :optional => true
  belongs_to :city, :optional => true
  belongs_to :venue, :optional => true

  has_many :newsitems

  set_callback(:create, :before) do |doc|
    if doc.user_profile && doc.user_profile.username
      doc.username = doc.user_profile.username
    end
    doc.galleryname = doc.id.to_s

    if doc.is_public 
      # for the sites
      if doc.site
        sites = Site.where( :domain => doc.site.domain )
        sites.each do |site|
          n = Newsitem.new {}
          n.gallery = doc
          n.username = doc.username
          site.newsitems << n
          flag = site.save
          if !flag
            puts! site.errors
          end
        end
      end

      # for the city
      if doc.city
        n = Newsitem.new {}
        n.gallery = doc
        n.city = doc.city
        n.username = doc.username
        n.save
      end
    end
  end

  # @deprecated, use Gallery::ACTIONS
  def self.actions
    [ 'show_mini', 'show_long', 'show' ]
  end
  ACTIONS = [ 'show_mini', 'show_long', 'show' ]

end

