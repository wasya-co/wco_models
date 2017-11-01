
class AppModel2
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :is_public,    :type => Boolean, :default => false
  field :is_trash,     :type => Boolean, :default => false

  default_scope ->{ where({ :is_public => true, :is_trash => false }).order_by({ :created_at => :desc }) }
  
  field :x, :type => Float
  field :y, :type => Float

  def self.list conditions = { :is_trash => false }
    out = self.where( conditions ).order_by( :created_at => :desc )
    [['', nil]] + out.map { |item| [ "#{item.created_at.strftime('%Y%m%d')} #{item.name}", item.id ] }
  end

  private

  def puts! arg, label=""
    puts "+++ +++ #{label}"
    puts arg.inspect
  end
  
end
