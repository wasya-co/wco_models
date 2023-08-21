
class Wco::ApplianceTmpl
  include Mongoid::Document
  include Mongoid::Timestamps

  field :kind
  validates :kind, uniqueness: true, presence: true

  field :image
  validates :image, presence: true

  KIND_CORPHOME1  = 'corphome1'
  KIND_HELLOWORLD = 'helloworld'
  KINDS = [ 'SMT', 'EmailCRM', KIND_CORPHOME1, KIND_HELLOWORLD, 'Drupal', 'Odoo', 'Mautic', 'IroWor', 'eCommStore1' ]
end
