require 'spec_helper'
describe 'CoTailors::OrderItem' do
  before :each do
    do_setup
  end

  it 'validates measurement, quantity, fabric, kind' do
    order = CoTailors::Order.create
    m = CoTailors::ProfileMeasurement.create
    params = { :order => order, :measurement => m, :quantity => 1, :kind => CoTailors::OrderItem::KIND_SHIRT,
               :fabric => 'white' }
    params.each do |k, v|
      temp_params = params.dup
      temp_params.delete k
      item = CoTailors::OrderItem.new temp_params
      item.save.should eql false
    end
    item = CoTailors::OrderItem.new params
    item.save.should eql true
  end

end
     
