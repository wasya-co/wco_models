
class ::Ish::EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  validates_uniqueness_of :slug, scope: [ :version ]
  validates_presence_of :slug

  field :version, default: '0.0.0'

  TYPES = %w| partial plain |
  field :type
  def self.type_list
    [ [nil,nil] ] + TYPES.map { |i| [i, i] }
  end

  field :subject
  field :body
  field :from_email

end
EmailTemplate = ::Ish::EmailTemplate
