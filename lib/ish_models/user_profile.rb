class IshModels::UserProfile  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username, :type => String
  field :name
  field :email

  field :fb_access_token
  field :fb_long_access_token

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

  belongs_to :user
  belongs_to :current_city, :class_name => 'City', :inverse_of => :current_users, :optional => true
  belongs_to :guide_city,   :class_name => 'City', :inverse_of => :guide,         :optional => true
 
  has_many :galleries
  has_many :reports, :inverse_of => :profile
  has_many :videos

  def sudoer?
    %w( piousbox@gmail.com manager@gmail.com ).include?( self.user.email ) ? true : false
  end

  # manager uses it.
  # @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ item.username, item.id ] }
  end

end
