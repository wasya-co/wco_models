
##
## it has start and duration.
##

=begin

ffmpeg \
  -i combined.mp4 \
  -i overlay_1.mp4 \
  -i overlay_2.mp4 \
  -filter_complex \
  "[1:v]setpts=PTS-STARTPTS+1.55/TB[v1];
   [2:v]setpts=PTS-STARTPTS+5.55/TB[v2];
   [0:v][v1]overlay=0:0:eof_action=pass[tmp];
   [tmp][v2]overlay=0:0:eof_action=pass[vout]" \
  -map "[vout]" \
  -map 0:a? \
  -c:v libx264 \
  -c:a copy \
  combined_2.mp4

=end

class Wco::Newsoverlay
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_newsoverlays'

  PAGE_PARAM_NAME = 'newsoverlays_page'

  belongs_to :video
  belongs_to :newsoverlay_config, optional: true
  belongs_to :newsvideo

  field :start_at_ms, type: :integer, default: 0
  field :duration_ms, type: :integer, default: 0

  delegate :duration_ms, to: :video
  delegate :name,        to: :video

end
