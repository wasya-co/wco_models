require 'spec_helper'

describe Video do

  it 'defaults' do
    video = build(:video)
    video.is_public.should eql false
  end

  it 'delete' do
    video = create(:video)
    video.is_trash.should eql false
    video.delete
    video.reload
    video.is_trash.should eql true
    video.deleted_at.strftime('%Y%m%d').should eql(Time.now.strftime('%Y%m%d'))
  end

  describe 'scopes, class methods' do
    before do
      @video_public = create(:video, is_public: true)
      @video_trash = create(:video, deleted_at: Time.now)
      @video_private = create(:video, is_public: false)
    end
  end

end



