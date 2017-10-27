
#
# Stock Option. Owned by a person. This is a position that is held (or historical data).
# _vp_ 20171026
#
class Ish::StockOption
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_stock_option'

  field :ticker
  field :expires_on, :type => Date
  field :strike, :type => Float

  DIRECTIONS = [ :CALL, :PUT ]
  field :direction, :type => Symbol

  field :quantity, :type => Integer
  field :is_active, :type => Integer, :default => true # whether this position is current or in the past

  belongs_to :profile,      :class_name => 'IshModels::UserProfile'
  belongs_to :stock_action, :class_name => 'Ish::StockAction', :optional => true

  def to_s
    "#{self.ticker} #{self.expires_on.to_time.strftime('%b %d %Y')} #{self.strike} (x #{self.quantity})"
  end

end
