
##
## Only object_key, no validations.
## 2023-12-28 _vp_ Continue.
## 2024-01-05 LFG
##
class WcoEmail::MessageStub
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'wco_email_message_stub'

  STATUS_PENDING   = 'status_pending'
  STATUS_PROCESSED = 'status_processed'
  STATUS_FAILED    = 'status_failed'
  STATUSES         = [ STATUS_PENDING, STATUS_PROCESSED ]
  field :status, default: STATUS_PENDING
  scope :pending, ->{ where( status: 'status_pending' ) }

  field     :object_key
  validates :object_key, presence: true, uniqueness: true
  index({ object_key: 1 }, { unique: true, name: "object_key_idx" })

  has_one :message,               class_name: 'WcoEmail::Message'

  has_and_belongs_to_many :tags,  class_name: 'Wco::Tag'

  field :config, type: Object, default: <<~AOL
    {}
  AOL

  ## This only saves a local messafe from mbox to s3.
  def do_process message
    the_mail = Mail.new(message)
    key      = the_mail.message_id || "no-key-#{Time.now.to_i}.#{rand(1000)}"

    @stub = WcoEmail::MessageStub.create({
      object_key:  key,
      status:      WcoEmail::MessageStub::STATUS_PENDING,
      tags:        [ @tag ],
    })
    if @stub.persisted?
      @client.put_object({ bucket: ::S3_CREDENTIALS[:bucket_ses],
        key: key,
        body: message,
      })
    else
      msg = @stub.errors.full_messages.join(", ")
      puts! msg
      Wco::Log.create({
        message:    "Stub duplicate object_key: #{key}",
        class_name: 'WcoEmail::MessageStub',
        raw_json:   @stub.attributes.to_json,
        tags:       [ @tag ],
      })
    end
  end

  def self.mbox2stubs mbox_path, tagname:, skip:
    skip ||= 0
    self.new.mbox2stubs mbox_path, tagname: tagname, skip: skip
  end
  def mbox2stubs mbox_path, tagname:, skip:
    puts 'Starting...'
    skip ||= 0

    @count = 1
    @client ||= Aws::S3::Client.new({
      region:            ::S3_CREDENTIALS[:region_ses],
      access_key_id:     ::S3_CREDENTIALS[:access_key_id_ses],
      secret_access_key: ::S3_CREDENTIALS[:secret_access_key_ses],
    })
    @tag = Wco::Tag.find_or_create_by({ slug: tagname })

    message    = nil
    File.readlines(mbox_path, encoding: "ISO8859-1" ).each do |line|
      if (line.match(/\AFrom /))

        if message
          if skip < @count
            do_process message
            print "#{@count}."
          else
            print "s-#{@count}."
          end
          @count += 1
        end
        message = ''

      else
        message << line.sub(/^\>From/, 'From')
      end
    end

    if message
      if skip < @count
        do_process message
        print "#{@count}."
      else
        print "s-#{@count}."
      end
      @count += 1
    end
    message = ''
  end

end
