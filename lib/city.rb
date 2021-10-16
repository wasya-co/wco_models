class City
  include ::Mongoid::Document
  include ::Mongoid::Timestamps
  include AuxModel

  field :name, :type => String
  field :description, :type => String, :default => 'The description of this city'

  field :cityname, :type => String
  validates :cityname, :uniqueness => true, :allow_nil => false, :presence => true
  def slug; cityname; end
  def slug= s; cityname = s; end

  field :x, :type => Float
  field :y, :type => Float

  field :deleted_at, type: Time
  def self.all
    self.where( deleted_at: nil, is_active: true ).order_by( name: :desc )
  end

  belongs_to :country, :optional => true

  has_many :events
  has_many :galleries
  has_many :photos
  has_many :reports
  has_many :venues
  has_many :videos
  has_and_belongs_to_many :tags

  has_many :current_users, :class_name => '::IshModels::UserProfile', :inverse_of => :current_city
  has_many :newsitems

  has_many :current_users, :class_name => '::IshModels::UserProfile', :inverse_of => :current_city
  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_city
  has_one :guide, :class_name => '::IshModels::UserProfile', :inverse_of => :guide_city

  has_many :features

  field :calendar_frame, :type => String
  field :is_active, type: Boolean, default: true

  default_scope ->{ order_by({ :name => :asc }) }

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
  def n_features
    4
  end


  def j_reports args = {}
    out =  []
    self.reports.each do |r|
      rr = r.clone
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

  def self.method_missing name, *args, &block
    city = City.where( :cityname => name ).first
    return city if city
    super
  end

end



