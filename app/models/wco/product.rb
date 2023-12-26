
class Wco::Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name

  field :product_id # stripe

  has_many :prices,        class_name: 'Wco::Price', inverse_of: :product

  def self.list
    [ [nil,nil] ] + self.all.order_by({ name: :asc }).map { |i| [i.name, i.id] }
  end

end


