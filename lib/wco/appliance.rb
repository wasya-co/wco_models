
class Wco::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :kind
  field :environment
  field :subdomain
  field :domain

  field :leadset_id
  belongs_to :profile, class_name: 'Ish::UserProfile', optional: true

end
