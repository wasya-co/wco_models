require 'spec_helper'

describe Gameui::Marker do
  before :each do
    # do_setup
  end

  it '#export' do
    marker = create(:marker, map: create(:map) )
    result = marker.export
    result[:_id].class.should eql String
  end

  it '#permitted_to' do
    map = create(:map)
    map_2 = create(:map)
    p1 = create(:profile)
    p2 = create(:profile)
    m1 = create(:marker, creator_profile: p1, is_public: false, map: map,
      destination: map_2,
    )
    m2 = create(:marker, creator_profile: p2, is_public: false, map: map,
      destination: map_2,
    )

    # mine
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql true
    results.include?(m2).should eql false

    # public
    m1.update_attributes( is_active: false )
    m2.update_attributes( is_public: true )
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql false
    results.include?(m2).should eql true

    # shared
    m2.shared_profiles << p1
    m2.is_public = false
    m2.save
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql false
    results.include?(m2).should eql true
  end

end



