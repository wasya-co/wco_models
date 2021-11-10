
class ::Gameui::MapBookmark
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :profile, class_name: 'Ish::UserProfile'
  belongs_to :location, class_name: '::Gameui::Map'

end
