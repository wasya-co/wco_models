
=begin

key = '01070861907736276273039d9ee-c69a3509-5c85-481d-822e-ba65c204e1ba-000000@eu-central-1.amazonses.com'

=end

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
  STATUSES         = [ STATUS_PENDING, STATUS_PROCESSED, STATUS_FAILED ]
  field :status, default: STATUS_PENDING
  scope :pending, ->{ where( status: STATUS_PENDING ) }

  field     :bucket # 'ish-ses', 'ish-ses-2024'

  field     :object_key
  validates :object_key, presence: true, uniqueness: true
  index({ object_key: 1 }, { unique: true, name: "object_key_idx" })

  has_one :message,               class_name: 'WcoEmail::Message'

  has_and_belongs_to_many :tags,  class_name: 'Wco::Tag'

  ##
  ## skip_notification
  ## process_images
  ##
  field :config, type: Object, default: <<~AOL
    {}
  AOL

  def do_process
    @client ||= Aws::S3::Client.new({
      region:            ::S3_CREDENTIALS[:region_ses],
      access_key_id:     ::S3_CREDENTIALS[:access_key_id_ses],
      secret_access_key: ::S3_CREDENTIALS[:secret_access_key_ses],
    })
    stub = self

    raw                = @client.get_object( bucket: stub.bucket, key: stub.object_key ).body.read
    the_mail           = Mail.new( raw )

    message_id         = the_mail.header['message-id']&.decoded
    message_id       ||= "#{the_mail.date&.iso8601}::#{the_mail.from}"
    # puts! message_id, 'message_id'

    in_reply_to_id     = the_mail.header['in-reply-to']&.to_s
    # puts! in_reply_to_id, 'in_reply_to_id'

    the_mail.to        = [ 'NO-RECIPIENT' ] if !the_mail.to
    subject            = WcoEmail::Message.strip_emoji( the_mail.subject || '(wco-no-subject)' )
    # puts! subject, 'subject'

    ## Conversation
    if in_reply_to_id
      in_reply_to_msg = WcoEmail::Message.where({ message_id: in_reply_to_id }).first
      if !in_reply_to_msg
        conv = WcoEmail::Conversation.find_or_create_by({
          subject: subject,
        })
        in_reply_to_msg = WcoEmail::Message.find_or_create_by({
          message_id: in_reply_to_id,
          conversation: conv,
        })
      end
      conv = in_reply_to_msg.conversation
    else
      conv = WcoEmail::Conversation.unscoped.find_or_create_by({
        subject: subject,
      })
      conv.deleted_at = nil
    end


    ## Leadset, Lead
    from      = the_mail.from ? the_mail.from[0] : "nobody@unknown-doma.in"
    domain    = from.split('@')[1]
    leadset   = Wco::Leadset.where(  company_url: domain ).first
    leadset ||= Wco::Leadset.create( company_url: domain, email: from )
    lead      = Wco::Lead.find_or_create_by( email: from, leadset: leadset )


    message   = WcoEmail::Message.unscoped.where( message_id: message_id ).first
    if message
      message.message_id = "#{Time.now.strftime('%Y%m%d')}-trash-#{message.message_id}"
      message.object_key = "#{Time.now.strftime('%Y%m%d')}-trash-#{message.object_key}"
      message.save!( validate: false )
      message.delete
    end

    @message = WcoEmail::Message.create!({
      stub:         stub,
      conversation: conv,
      lead:         lead,

      message_id:     message_id,
      in_reply_to_id: in_reply_to_id,
      object_key:     stub.object_key,

      subject: subject,
      date:    the_mail.date,

      from:  from,
      froms: the_mail.from,

      to:  the_mail.to ? the_mail.to[0] : nil,
      tos: the_mail.to,

      cc:  the_mail.cc ? the_mail.cc[0] : nil,
      ccs:  the_mail.cc,
    })
    puts! @message, '@message'

    ## Parts
    the_mail.parts.each do |part|
      @message.churn_subpart( part )
    end
    @message.save

    if the_mail.parts.length == 0
      body = the_mail.body.decoded.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      if the_mail.content_type&.include?('text/html')
        @message.part_html = body
      elsif the_mail.content_type&.include?('text/plain')
        @message.part_txt = body
      elsif the_mail.content_type.blank?
        @message.part_txt = body
      else
        @message.logs.push "mail body of unknown type: #{the_mail.content_type}"
      end
      @message.save
    end

    ## Attachments
    the_mail.attachments.each do |att|
      @message.save_attachment( att )
    end

    if !@message.save
      puts! @message.errors.full_messages.join(", "), "Could not save @message"
    end


    conv.leads.push lead
    conv.save

    the_mail.cc&.each do |cc|
      domain  = cc.split('@')[1] rescue 'unknown.domain'
      leadset = Wco::Leadset.find_or_create_by( company_url: domain )
      Wco::Lead.find_or_create_by( email: cc, leadset: leadset )
    end

    conv.update_attributes({
      status:      WcoEmail::Conversation::STATUS_UNREAD,
      latest_at:   the_mail.date || Time.now.to_datetime,
      from_emails: ( conv.from_emails + the_mail.from ).uniq,
      preview:     @message.preview_str,
    })

    ##
    ## Tags
    ##
    conv.tags.push Wco::Tag.inbox
    conv.tags.push stub.tags
    conv.save


    ## Actions & Filters
    email_filters = WcoEmail::EmailFilter.active
    email_filters.each do |filter|
      reson = nil
      if filter.from_regex.present? && @message.from.downcase.match( filter.from_regex )
        reason = 'from_regex'
      end
      if filter.from_exact.present? && @message.from.downcase.include?( filter.from_exact.downcase )
        reason = 'from_exact'
      end
      if filter.body_exact.present? && @message.part_html&.include?( filter.body_exact )
        reason = 'body_exact'
      end
      if filter.subject_regex.present? && @message.subject.match( filter.subject_regex )
        reason = 'subject_regex'
      end
      if filter.subject_exact.present? && @message.subject.downcase.include?( filter.subject_exact.downcase )
        reason = 'subject_exact'
      end

      if reason
        puts! "Applying filter #{filter} to conv #{conv} for matching #{reason}" if DEBUG
        @message.apply_filter( filter )
      end
    end

    stub.update_attributes({ status: WcoEmail::MessageStub::STATUS_PROCESSED })

    ## Notification
    config = JSON.parse(stub.config)
    if config['skip_notification']
      ;
    else
      conv = WcoEmail::Conversation.find( conv.id )
      if conv.tags.include? Wco::Tag.inbox
        out = WcoEmail::ApplicationMailer.forwarder_notify( @message.id.to_s )
        Rails.env.production? ? out.deliver_later : out.deliver_now
      end
    end

    puts 'ok'
  end

  ## This only saves a local message from mbox to s3.
  def save_mbox_to_m3 message
    the_mail = Mail.new(message)
    key      = the_mail.message_id || "no-key-#{Time.now.to_i}.#{rand(1000)}"

    @stub = WcoEmail::MessageStub.create({
      bucket:      ::S3_CREDENTIALS[:bucket_ses],
      object_key:  key,
      status:      WcoEmail::MessageStub::STATUS_PENDING,
      tags:        [ @tag ],
    })
    if @stub.persisted?
      @client.put_object({
        body: message,
        bucket: ::S3_CREDENTIALS[:bucket_ses],
        key: key,
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
            save_mbox_to_m3 message
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
        save_mbox_to_m3 message
        print "#{@count}."
      else
        print "s-#{@count}."
      end
      @count += 1
    end
    message = ''
  end

end
