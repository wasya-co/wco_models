class IshModels::UserProfile  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  validates_presence_of :name

  field :username
  
  field :email
  # validates_format_of :email, :with => ::Devise::email_regexp
  validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  field :fb_access_token
  field :fb_long_access_token
  field :fb_expires_in

  field :about, :type => String
  field :education, :type => String
  field :objectives, :type => String
  field :current_employment, :type => String
  field :past_employment, :type => String
  
  field :pdf_resume_path, :type => String
  field :doc_resume_path, :type => String
  
  field :lang, :type => String, :default => :en

  ROLES = [ :admin, :manager, :guy ] 
  field :role_name, :type => Symbol

  TAGS = [ :social, :professional ]
  field :tag, :type => Symbol

  belongs_to :user
  belongs_to :current_city, :class_name => 'City', :inverse_of => :current_users, :optional => true
  belongs_to :guide_city,   :class_name => 'City', :inverse_of => :guide,         :optional => true
 
  has_many :galleries, :inverse_of => :user_profile
  has_and_belongs_to_many :shared_galleries, :class_name => 'Gallery', :inverse_of => :shared_profiles

  has_many :invoices, :class_name => 'Ish::Invoice'
  has_many :leads,    :class_name => 'Ish::Lead'
  has_many :photos
  has_many :reports, :inverse_of => :user_profile
  has_many :stocks,   :class_name => 'Ish::StockWatch'
  has_many :videos, :inverse_of => :user_profile

  has_and_belongs_to_many :friends,   :class_name => 'IshModels::UserProfile', :inverse_of => :friendeds
  has_and_belongs_to_many :friendeds, :class_name => 'IshModels::UserProfile', :inverse_of => :friends

  #
  # preferences
  #
  field :videos_embed, :type => Boolean, :default => false

  def sudoer?
    %w( piousbox@gmail.com manager@gmail.com ).include?( self.user.email ) ? true : false
  end

  # manager uses it.
  # @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ item.name, item.id ] }
  end

  # colombia tailors
  has_one  :measurement,  :class_name => '::CoTailors::ProfileMeasurement'
  has_many :addresses,    :class_name => '::CoTailors::Address'
  has_many :orders,       :class_name => '::CoTailors::Order'

  def current_order
    self.orders.where( :submitted_at => nil ).first || CoTailors::Order.create( :profile => self )
  end

end
