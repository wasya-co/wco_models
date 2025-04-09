

class Wco::Log
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_logs'

  field :label,   type: :string ## can be the stream: 'stdout' or 'stderr'
  field :message, type: :string ## can be json

  belongs_to :obj, polymorphic: true, optional: true

  has_and_belongs_to_many :tags

  def self.puts! message, label, obj: nil
    create( message: message.to_s, label: label.to_s, obj: obj.to_s )
    puts "+++ +++ #{label}:"
    puts message.inspect
  end

  def to_s
    "#{created_at} #{message}"
  end
end
