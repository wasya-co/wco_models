class AppModel2
  include ::Mongoid::Document
  include ::Mongoid::Timestamps

  field :is_feature, :type => Boolean, :default => false
  field :is_public, :type => Boolean, :default => false
  field :is_done, :type => Boolean, :default => false
  field :is_trash, :type => Boolean, :default => false
  field :is_anonymous, :type => Boolean, :default => false

  scope :fresh, ->{ where({ :is_trash => false }) }
  scope :trash, ->{ where({ :is_trash => true }) }
  scope :public, ->{ where({ :is_public => true }) }
  scope :done, ->{ where({ :is_done => true }) }

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
