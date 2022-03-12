require 'spec_helper'

describe Gameui::Map do
  before :each do
    do_setup
  end

  it '#collect' do
    map = create(:map)
    result = map.collect Gameui::Map::EMPTY_EXPORT
    result[:maps].should eql([ map.id ])
  end

  it '#export' do
    map = create(:map)
    result = map.export
    result[:id].should_not eql nil
    result[:slug].should eql map.slug
  end

  it '#export_subtree' do
    map = create(:map)
    result = map.export_subtree
    pputs! result, 'results'
  end

end



