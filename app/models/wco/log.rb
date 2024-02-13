

class Wco::Log
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_logs'

  field :label,   type: :string
  field :message, type: :string

  belongs_to :obj, polymorphic: true, optional: true

  has_and_belongs_to_many :tags

  def self.puts! message, label, obj: nil
    create( message: message, label: label, obj: obj )
    puts "+++ +++ #{label}:"
    puts message.inspect
  end

  def to_s
    "#{created_at} #{message}"
  end
end
