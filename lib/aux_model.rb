
module AuxModel

  def add_newsitem item
    n = Newsitem.new
    case item.class.name
    when 'Video'
      n.video_id = item.id
    when 'Photo'
      raise 'Not Implemented'
    when 'Report'
      raise 'Not Implemented'
    when 'Gallery'
      raise 'Not Implmented'
    else
      raise 'Not Implemented'
    end
    self.newsitems << n
    self.save
  end

end
