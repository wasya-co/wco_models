class City
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :name, :type => String

  field :description, :type => String, :default => 'The description of this city'

  field :cityname, :type => String
  validates :cityname, :uniqueness => true, :allow_nil => false, :presence => true
  
  field :name_en, :type => String, :default => ''
  # validates :name_en, :uniqueness => true, :allow_nil => false, :presence => true

  field :name_ru, :type => String, :default => ''
  # validates :name_ru, :uniqueness => true, :allow_nil => false, :presence => true

  field :name_pt, :type => String, :default => ''
  # validates :name_pt, :uniqueness => true, :allow_nil => false, :presence => true
  
  field :is_feature, :type => Boolean, :default => false
  
  field :x, :type => Float
  field :y, :type => Float
  
  belongs_to :country, :optional => true
 
  has_many :events 
  has_many :galleries 
  has_many :photos
  has_many :reports
  has_many :venues
  has_many :videos
  has_many :tags
  has_many :current_users, :class_name => '::IshModels::UserProfile', :inverse_of => :current_city

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_city
  has_one :guide, :class_name => '::IshModels::UserProfile', :inverse_of => :guide_city

  has_many :newsitems

  # @TODO @deprecated, I wish I don't use it.
  field :n_newsitems, :type => Integer, :default => 16

  embeds_many :features
  # @TODO @deprecated, I wish I don't use it.
  field :n_features, :type => Integer, :default => 4

  field :calendar_frame, :type => String
  
  default_scope ->{ order_by({ :name => :asc }) }

  def self.feature
    where( :is_feature => true )
  end
  
  def self.non_feature
    where( :is_feature => false )
  end
  
  def self.list
    out = self.order_by( :name => :asc )
    # no_city = City.where( :cityname => 'no_city' ).first || City.create( :cityname => 'no_city', :name => 'No City' )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  def self.list_citynames lang = 'en'
    out = self.order_by( :name => :asc )
    [['', nil]] + out.map { |item| [ item['name_'+lang], item.cityname ] }
  end

  def self.clear
    if Rails.env.test?
      City.all.each { |r| r.remove }
    end
  end

  def self.n_features
    4
  end

  def j_reports args = {}
    out =  []
    self.reports.each do |r| # .page( params[:reports_page] 
      rr = r.clone
      # rr[:photo_url] = r.photo.photo.url( :mini ) unless r.photo.blank?
      # rr[:photo_url] ||= '/assets/missing.png'
      rr[:username] = r.user.username
      rr.created_at = r.created_at # pretty_date( r.created_at )
      rr[:tag_name] = r.tag.name unless r.tag.blank?
      rr[:tag_name] ||= ''
      out << rr
    end
    return out
  end

  def self.for_homepage
    cities = City.all.order_by( :name => :asc )
    cities = cities.delete_if do |c|
      ( false == c.is_feature ) && ( 0 == c.galleries.length ) && ( 0 == c.reports.length )
    end
    return cities
  end

  def self.feature
    City.where( :is_feature => true )
  end

  def add_newsitem doc
    # puts! self.newsitems, "city newsitems are"
    if 'Video' == doc.class.name
      self.newsitems << Newsitem.new({ :descr => '', :username => '', :video => doc })
    end
  end
 
  def self.method_missing name, *args, &block
    city = City.where( :cityname => name ).first
    return city if city
    super
  end
   
end



