require 'spec_helper'

describe Video do

  it '#create, defaults' do
    video = build(:video)
    video.is_public.should eql false
    video.youtube_id.should eql nil
    video.save.should eql true
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

  describe 'voting' do
    it 'votes' do
      video = create(:video)
      profile = create(:user_profile)

      video.votes_count.should eql 0
      video.votes_point.should eql 0

      # profile.vote(video, :up)
      video.vote( voter_id: profile.id, value: :up )
      video.reload

      video.votes_count.should eql 1
      video.votes_point.should eql 1
    end
  end

end



