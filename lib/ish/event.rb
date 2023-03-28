
class Ish::Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :start_at, type: ActiveSupport::TimeWithZone
  index({ start_at: 1 })

  field :end_at, type: ActiveSupport::TimeWithZone

  field :name
  index({ name: 1 })

  field :descr

  field :is_public, type: :boolean, default: false
  index({ is_public: 1 })

end

