class UserProfile  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :username, :type => String

  field :about, :type => String
  field :education, :type => String
  field :objectives, :type => String
  field :current_employment, :type => String
  field :past_employment, :type => String
  
  field :pdf_resume_path, :type => String
  field :doc_resume_path, :type => String
  
  field :lang, :type => String
 
  belongs_to :user

  has_many :galleries
  
  def manager?
    %w( piousbox@gmail.com manager@gmail.com ).include?( self.user.email ) ? true : false
  end

  # manager uses it.
  # @TODO: check this, this is shit. _vp_ 20170527
  def self.list
    out = self.all.order_by( :domain => :asc, :lang => :asc )
    [['', nil]] + out.map { |item| [ item.username, item.id ] }
  end

end
