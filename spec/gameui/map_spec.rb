require 'spec_helper'

describe Gameui::Map do
  before :each do
    do_setup
  end

  it 'has one left_item' do 
    Gameui::Map.reflect_on_association(:left_item).class.should eql Mongoid::Association::Referenced::HasOne
  end

  it '#collect' do
    map = create(:map)
    result = map.collect Gameui::Map.empty_export
    result[:maps].should eql({ map.id.to_s => map.id.to_s })
  end

  it '#export' do
    map = create(:map)
    result = map.export
    result[:_id].should_not eql nil
    result[:slug].should eql map.slug
  end

  it '#export_subtree' do
    map = create(:map)
    result = map.export_subtree
    result['image_assets'].length.should > 0
  end

end



