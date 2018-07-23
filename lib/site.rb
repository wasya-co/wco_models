class Site

  include Mongoid::Document
  include Mongoid::Timestamps
  include AuxModel

  field :domain, :type => String

  field :lang, :type => String, :default => 'en'
  # validates :lang, { :uniqueness => :true, :scope => :domain }

  field :title
  field :subhead
  field :description
  field :home_redirect_path

  field :n_features,             :type => Integer, :default => 4
  field :n_newsitems,            :type => Integer, :default => 20
  field :newsitems_per_page,     :type => Integer, :default => 10 # this is used. _vp_ 20171025
  field :play_videos_in_preview, :type => Boolean, :default => true

  # denormalized
  field :n_reports, :type => Integer
  field :n_galleries, :type => Integer

  field :is_video_enabled, :type => Boolean, :default => false
  field :is_resume_enabled, :type => Boolean, :default => false
  field :is_ads_enabled, :type => Boolean, :default => true
  field :is_trash, :type => Boolean, :default => false
  field :is_primary, :type => Boolean, :default => false
  field :is_private, :type => Boolean, :default => false
  field :private_user_emails, :type => Array, :default => []
  
  field :homepage_layout, :type => String, :default => 'show'
  field :layout, :type => String, :default => 'application'

  has_many :reports
  has_many :galleries
  has_many :tags
  has_many :videos
  has_many :newsitems, :order => :created_at.desc
  has_many :issues, :class_name => 'Ish::Issue'

  embeds_many :features, :order => :created_at.desc
  
  default_scope ->{ where({ :is_trash => false }).order_by({ :domain => :asc, :lang => :asc }) }

  set_callback :create, :before do |doc|
    if Site.where( :lang => doc.lang, :domain => doc.domain ).length > 0
      false
    end
  end

  set_callback :update, :before do |doc|
    possible_duplicate = Site.where( :lang => doc.lang, :domain => doc.domain ).first
    if possible_duplicate.blank?
      true
    elsif doc.id != possible_duplicate.id
      false
    end
  end

  LANGUAGES = [ 'en', 'ru', 'pt' ]
  
  # manager uses it.
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['Select Site', nil]] + out.map { |item| [ "#{item.domain} #{item.lang}", item.id ] }
  end

  def self.mobi
    Site.where( :domain => 'travel-guide.mobi', :lang => 'en' ).first
  end

  def n_reports
    self.reports.unscoped.where( :is_trash => false ).length
  end

  def n_private_reports
    self.reports.unscoped.where( :is_public => false, :is_trash => false ).length
  end
  
  def its_locales
    Site.where( :domain => self.domain ).map { |s| s.lang.to_sym }
  end

  def self.Tgm
    Site.find_by( :domain => 'travel-guide.mobi', :lang => :en )
  end
  def self.sedux
    site   = Site.where( :domain => 'sedux.local' ).first
    site ||= Site.where( :domain => 'sedux.net'   ).first
    site
  end

  def name
    "#{domain}/#{lang}"
  end

end
