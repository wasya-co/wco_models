class Venue
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :name, :type => String
  validates :name, :uniqueness => true, :allow_nil => false

  field :name_seo, :type => String
  validates :name_seo, :uniqueness => true, :allow_nil => false
  
  field :subhead
  field :descr
  
  field :is_trash, :type => Boolean, :default => false
  scope :fresh, ->{ where({ :is_trash => false }) }
  scope :trash, ->{ where({ :is_trash => true }) }

  field :is_public, :type => Boolean, :default => true
  scope :public,     ->{ where({ :is_public => true }) }
  scope :not_public, ->{ where({ :is_public => false }) }

  field :is_feature, :type => Boolean, :default => false

  field :x, :type => Float
  field :y, :type => Float

  field :lang, :type => String, :default => 'en'

  belongs_to :city
  # belongs_to :owner, :class_name => 'User', :inverse_of => :owned_venue
  validates :city, :allow_nil => false, :presence => true

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :users

  has_one :profile_photo, :class_name => 'Photo', :inverse_of => :profile_venue

  has_many :reports
  has_many :galleries
  has_many :photos

  embeds_many :newsitems
  embeds_many :features

  def self.list conditions = { :is_trash => false }
    out = self.where( conditions).order_by( :name => :asc )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  set_callback :create, :before do |doc|
    doc.name_seo = doc.name.gsub(' ', '-')
  end

  set_callback :save, :before do |doc|
    if doc.city
      city.touch
    end
  end

  def self.types
    return []
#    if 'en' == @locale
#      [ 'Hotels', 'Restaurants', 'Bars' ]
#    else
#      [ 'Hotels', 'Restaurants', 'Bars' ]
#    end
  end

  def self.n_features
    6
  end

end
