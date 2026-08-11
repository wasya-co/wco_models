

class Wco::Newsvideo
  include Mongoid::Document
  include Mongoid::Timestamps
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

  def do_split
    @newsvideo = self

    sentences = PragmaticSegmenter::Segmenter.new(text: @newsvideo.body).segment
    phrases = sentences_to_phrases(sentences)

    phrases.each_with_index do |phrase, idx|
      newspartial = Wco::Newspartial.new body: phrase, newsvideo: @newsvideo, slug: "#{sprintf("%02d", idx)}0"
      newspartial.save!
    end
  end


  def generate
    @newsvideo = self
    workdir    = Rails.root.join('tmp', @newsvideo.id.to_s)
    partials   = @newsvideo.newspartials.order_by(slug: :asc).to_a

    ## put together config, first thing
    cmd = "cd #{Rails.root.join('tmp')} ; rm -rf #{@newsvideo.id} ; mkdir -p #{@newsvideo.id} ; cd #{@newsvideo.id} ; "
    partials.each_with_index do |_part, idx|
      cmd = "#{cmd} echo \"file 'synced_#{idx}.mp4'\" >> syncedlist.txt ; "
    end
    puts "+++ config cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## get base files locally
    cmd = "cd #{workdir} ; "
    partials.each_with_index do |part, idx|
      cmd = "#{cmd} wget -nc -O newspartial_#{idx}.webm #{part.video.video.url} ; "
      cmd = "#{cmd} [ -f newspartial_#{idx}.mp4 ] || ffmpeg -y -i newspartial_#{idx}.webm -r 24 -pix_fmt yuv420p newspartial_#{idx}.mp4 ; "
      cmd = "#{cmd} wget -nc -O newspartial_#{idx}.wav #{part.audio.url} ; "
    end
    puts "+++ base files cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'

    ## Sync each newspartial's sound to its video, then we'll merge those clips
    partials.each_with_index do |_part, idx|
      cmd = <<~AOL
        cd #{workdir} ;
        rm -f synced_#{idx}.mp4 ;
        ffmpeg -y -i newspartial_#{idx}.mp4 -i newspartial_#{idx}.wav \
          -map 0:v:0 \
          -map 1:a:0 \
          -c:v libx264 \
          -pix_fmt yuv420p \
          -c:a aac \
          -shortest \
          synced_#{idx}.mp4 ;
      AOL
      puts "+++ per-partial #{idx} sync cmd:"
      puts cmd
      out = `#{cmd}`
      puts! out, 'out'
    end

    ## merge synced newspartials into combined_base
    cmd = <<~AOL
      cd #{workdir} ;
      rm -f combined_base.mp4 ;
      ffmpeg -y -f concat -safe 0 -i syncedlist.txt -c:v libx264 -pix_fmt yuv420p \
        -c:a aac \
        -vsync cfr \
        -af "aresample=async=1:first_pts=0" \
        combined_base.mp4 ;
    AOL
    puts "+++ synced concat cmd:"
    puts cmd
    out = `#{cmd}`
    puts! out, 'out'




    ## overlays
    if @newsvideo.newsoverlays.length > 0
      ## get overlays
      cmd = "cd #{Rails.root.join('tmp', @newsvideo.id)} ; "
      @newsvideo.newsoverlays.each_with_index do |overlay, idx|
        cmd = "#{cmd} wget -nc -O overlay_#{idx}.mp4 #{overlay.video.video.url} ; "
      end
      puts "+++ overlays cmd:"
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

      nn.each_with_index do |ms, idx|
        ffmpeg_cmd.push "[#{idx+1}:v]setpts=PTS-STARTPTS+#{ms.to_f/1000}/TB[v#{idx+1}]; \\"
      end

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

      ## combine overlays 2
      cmd = <<~AOL
        cd #{Rails.root.join('tmp', @newsvideo.id)} ;
        rm -f combined_fin.mp4 ;
        #{ffmpeg_cmd} ;
      AOL
      puts "+++ ffmpeg cmd 2:"
      puts cmd
      out = `#{cmd}`
      puts! out, 'out'
    else
      cmd = `cd #{workdir} ; mv combined_base.mp4 combined_fin.mp4`
    end

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

  def sentences_to_phrases sentences
    phrases = []
    current_phrase = []

    current_word_count = 0

    sentences.each do |sentence|
      words_in_sentence = sentence.split.size

      # If adding this sentence exceeds the limit, start a new phrase
      if current_word_count + words_in_sentence > Wco::Newspartial::MAX_WORDS
        phrases << current_phrase.join(" ")
        current_phrase = []
        current_word_count = 0
      end

      current_phrase << sentence
      current_word_count += words_in_sentence
    end

    # Add the last phrase if any
    phrases << current_phrase.join(" ") unless current_phrase.empty?
  end

end
