
class UserProfile
  
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :about, :type => String
  field :education, :type => String
  field :objectives, :type => String
  field :current_employment, :type => String
  field :past_employment, :type => String
  
  field :pdf_resume_path, :type => String
  field :doc_resume_path, :type => String
  
  field :lang, :type => String
  
  belongs_to :user
  
end
