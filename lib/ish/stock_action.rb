
#
# Stock action. Used to act on the existing inventory (before acting to aquire inventory)
# _vp_ 20171026
#
class Ish::StockAction
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in :collection => 'ish_stock_action'

  belongs_to :profile, :class_name => 'IshModels::UserProfile'
  belongs_to :stock_watch, :class_name => 'Ish::StockWatch'
  has_many :stock_options, :class_name => 'Ish::StockOption'

  field :is_active, :type => Boolean, :default => true # whether anything will be done upon alert trigger

end
