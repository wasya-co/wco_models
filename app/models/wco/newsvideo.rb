

class Wco::Newsvideo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Wco::Utils
  store_in collection: 'wco_newsvideos'

  PAGE_PARAM_NAME = 'newsvideos_page'

  field :title
  validates :title, presence: true, uniqueness: true
  index({ title: 1 }, { unique: true })
  def name ; title ; end
  def to_s
    title
  end

  field :slug
  validates :slug, presence: true, uniqueness: true
  index({ :slug => 1 }, { :unique => true })
  before_validation :set_slug, on: :create

  field :body
  field :config_json, type: :string
  field :duration_ms, type: :integer

  field :w_px, type: Integer
  field :h_px, type: Integer
  field :x, :type => Float
  field :y, :type => Float
  field :z, :type => Float

  # has_one :image_thumb
  # has_one :image_hero

  belongs_to :author, class_name: 'Wco::Profile'

  has_many :newspartials
  def newspartials
    Wco::Newspartial.where( newsvideo_id: self.id )
  end

  has_many :newsoverlay_configs
  has_and_belongs_to_many :tags
  has_many :videos


  has_many :newsoverlays
  def newsoverlays
    Wco::Newsoverlay.where( newsvideo_id: self.id )
  end

  def generate
    @newsvideo = self

    ## put together config, first thing
    cmd = "cd #{Rails.root.join('tmp')} ; mkdir -p #{@newsvideo.id} ; cd #{@newsvideo.id} ; rm -f videolist.txt audiolist.txt ; "
    @newsvideo.newspartials.each_with_index do |part, idx|
      cmd = "#{cmd} echo \"file 'newspartial_#{idx}.mp4' \" >> videolist.txt ; "
      cmd = "#{cmd} echo \"file 'newspartial_#{idx}.wav' \" >> audiolist.txt ; "
    end
    puts "+++ config cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## get base files locally
    cmd = "cd #{Rails.root.join('tmp', @newsvideo.id)} ; "
    @newsvideo.newspartials.each_with_index do |part, idx|
      cmd = "#{cmd} wget -nc -O newspartial_#{idx}.webm #{part.video.video.url} ; "
      cmd = "#{cmd} [ -f newspartial_#{idx}.mp4 ] || ffmpeg -y -i newspartial_#{idx}.webm newspartial_#{idx}.mp4 ; "
      cmd = "#{cmd} wget -nc -O newspartial_#{idx}.wav #{part.audio.url} ; "
    end
    puts "+++ base files cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## get overlays
    cmd = "cd #{Rails.root.join('tmp', @newsvideo.id)} ; "
    @newsvideo.newsoverlays.each_with_index do |overlay, idx|
      cmd = "#{cmd} wget -nc -O overlay_#{idx}.mp4 #{overlay.video.video.url} ; "
    end
    puts "+++ overlays cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## video concat
    cmd = <<AOL
      cd #{Rails.root.join('tmp', @newsvideo.id)} ;
      rm -f video_concat.mp4 ;
      ffmpeg -y -f concat -safe 0 -i videolist.txt -c copy video_concat.mp4 ;
AOL
    puts "+++ video concat cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## audio concat
    audio_filenames = (0...@newsvideo.newspartials.length).map { |i| "newspartial_#{i}.wav" }.join("|")
    cmd = <<AOL
      cd #{Rails.root.join('tmp', @newsvideo.id)} ;
      rm -f audio_concat.wav ;
      ffmpeg -y -f concat -safe 0 -i audiolist.txt -c copy audio_concat.wav ;
AOL
    puts "+++ audio concat cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## combine base
    cmd = <<AOL
      cd #{Rails.root.join('tmp', @newsvideo.id)} ;
      rm -f output.mp4 ;
      ffmpeg -y -i video_concat.mp4 -i audio_concat.wav -c:v copy -c:a aac combined_base.mp4 ;
AOL
    puts "+++ combine base cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ##  combine overlays
    nn = @newsvideo.newsoverlays.map { |ol| ol.start_at_ms }
    puts! nn, 'nn'
    ffmpeg_cmd = [ "ffmpeg -y -i combined_base.mp4 \\" ]
    nn.each_with_index do |ms, idx|
      ffmpeg_cmd.push " -i overlay_#{idx}.mp4 \\"
    end
    ffmpeg_cmd.push "-filter_complex \"\\"
    #
    nn.each_with_index do |ms, idx|
      ffmpeg_cmd.push "[#{idx+1}:v]setpts=PTS-STARTPTS+#{ms.to_f/1000}/TB[v#{idx+1}]; \\"
    end
    #
    curr_s = "0:v"
    n = nil
    nn.each_with_index do |ms, idx|
      n = idx+1
      ffmpeg_cmd.push "[#{curr_s}][v#{n}]overlay=0:0:eof_action=pass[tmp#{n}]#{idx+1<nn.length ? ';' : ''} \\"
      curr_s = "tmp#{n}"
    end
    ffmpeg_cmd.push " \" -map \"[#{curr_s}]\" -map 0:a? -c:v libx264 -c:a copy combined_fin.mp4 "
    ffmpeg_cmd = ffmpeg_cmd.join("\n")
    puts "+++ ffmpeg_cmd:"
    puts ffmpeg_cmd

    # combine overlays 2
    cmd = <<AOL
      cd #{Rails.root.join('tmp', @newsvideo.id)} ;
      rm -f combined_fin.mp4 ;
      #{ffmpeg_cmd} ;
AOL
    puts "+++ ffmpeg cmd 2:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## upload the video.
    @video = Wco::Video.new name: @newsvideo.title
    video_path = Rails.root.join("tmp", @newsvideo.id, "combined_fin.mp4")
    @video.video = File.open(video_path)
    flag = @video.save
    if !flag
      puts "Could not create video:"
      puts @video.errors.full_messages.join(", ")
    end
  end

end
