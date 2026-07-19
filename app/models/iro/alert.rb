
class Iro::Alert
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'iro_alerts'

  # SLEEP_TIME_SECONDS = Rails.env.production? ? 60 : 15

  DIRECTION_ABOVE = 'ABOVE'
  DIRECTION_BELOW = 'BELOW'
  def self.directions_list
    [ nil, DIRECTION_ABOVE, DIRECTION_BELOW ]
  end

  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUSES        = [ nil, 'active', 'inactive' ]
  field :status, default: STATUS_ACTIVE
  def self.active
    where( status: STATUS_ACTIVE )
  end

  field :class_name, default: 'Iro::Stock'
  validates :class_name, presence: true

  field :symbol, type: String
  validates :symbol, presence: true

  field :direction, type: String
  validates :direction, presence: true

  field :strike, type: Float
  validates :strike, presence: true

  def do_run
    alert = self
    begin
      price = Tda::Stock.get_quote( alert.symbol )&.last
      return if !price

      if ( alert.direction == alert.class::DIRECTION_ABOVE && price >= alert.strike ) ||
         ( alert.direction == alert.class::DIRECTION_BELOW && price <= alert.strike )

        if Rails.env.production?
          Iro::AlertMailer.stock_alert( alert.id.to_s ).deliver_later
        else
          Iro::AlertMailer.stock_alert( alert.id.to_s ).deliver_now
        end
        alert.update({ status: alert.class::STATUS_INACTIVE })
        print '^'

      end
    rescue => err
      puts! err, 'err'
      ::ExceptionNotifier.notify_exception(
        err,
        data: { alert: alert }
      )
    end
  end

end
