
require 'sidekiq'
require 'net/ssh'

class Wco::NewsvideoIllustrationJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform id, image_url
    puts! [ id, image_url ], 'NewsvideoIllustrationJob#perform...'
    @newsvideo = Wco::Newsvideo.unscoped.find id

    cmd = " cd /opt/projects/simple_ai_1/src/Stability ; \
      wget --user-agent='Mozilla/5.0' -O input.png #{image_url} ";

    cmd_1 = " . zenv_stability/bin/activate ; \
      rm -rf out ; \
      python scripts/minimal_run_cont.py ";

    cmd_2 = " ffmpeg -framerate 7 -i out/frames/frame_%04d.png -c:v libx264 -pix_fmt yuv420p out/output.mp4 ; \

      curl -v -X POST '#{WCO_ORIGIN_2}/wco/api/videos/?api_key=#{SIMPLE_API_KEY}&api_secret=#{SIMPLE_API_SECRET}' \
        -H 'Accept: application/json' \
        -F 'video=@out/output.mp4' \
        -F 'thumb=@out/frames/frame_0000.png' \
        -F 'name=#{@newsvideo.title}' \
        -F 'newsvideo_id=#{id}' ";

    out = `ssh pc-ai " whoami ; pwd ; #{cmd} ; #{cmd_1} ; #{cmd_2} ; "`
    puts! out, 'out'
  end

end
