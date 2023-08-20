
class Wco::Appliance
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :kind
  field :environment

  field :subdomain
  field :domain
  def host
    "#{subdomain}.#{domain}"
  end

  field :leadset_id
  belongs_to :profile, class_name: 'Ish::UserProfile', optional: true

  KIND_CORPHOME1  = 'corphome1'
  KIND_HELLOWORLD = 'helloworld'
  KINDS = [ 'SMT', 'EmailCRM', KIND_CORPHOME1, KIND_HELLOWORLD, 'Drupal', 'Odoo', 'Mautic', 'IroWor', 'eCommStore1' ]
end
