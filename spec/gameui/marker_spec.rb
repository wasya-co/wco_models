require 'spec_helper'

describe Gameui::Marker do
  before :each do
    # do_setup
  end

  it '#export' do
    map = create(:map)
    marker = create(:marker, map: map )
    result = marker.export
    result[:_id].class.should eql String
  end

  it '#permitted_to' do
    map = create(:map)
    map_1 = create(:map)
    map_2 = create(:map)
    p1 = create(:profile)
    p2 = create(:profile)
    m1 = create(:marker,
      name: 'marker-1',
      creator_profile: p2,
      destination: map_1,
      is_public: true,
      map: map,
    )
    m2 = create(:marker,
      name: 'marker-2',
      creator_profile: p2,
      destination: map_2,
      is_public: false,
      map: map,
    )

    # mine
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql true # b/c public, active
    results.include?(m2).should eql false # not public

    # public
    m1.update_attributes( is_active: false )
    m2.update_attributes( is_public: true )
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql false # b/c not active
    results.include?(m2).should eql true # public and active

    # shared
    m2.shared_profiles << p1
    m2.is_public = false
    m2.save
    results = Gameui::Marker.permitted_to(p1)
    results.include?(m1).should eql false
    results.include?(m2).should eql true
  end

end



