
class ::Ish::EmailTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :slug
  validates_uniqueness_of :slug, scope: [ :version ]
  validates_presence_of :slug

  field :version, default: '0.0.0'

end
EmailTemplate = ::Ish::EmailTemplate
