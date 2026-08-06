
=begin

key = '01070861907736276273039d9ee-c69a3509-5c85-481d-822e-ba65c204e1ba-000000@eu-central-1.amazonses.com'

=end

##
## Only object_key, no validations.
## 2023-12-28 _vp_ Continue.
## 2024-01-05 LFG
## 2026-07-10 LFG
##
class WcoEmail::MessageStub
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'wco_email_message_stub'

  PAGE_PARAM_NAME = 'stubs_page'

  STATUS_PENDING   = 'status_pending'
  STATUS_PROCESSED = 'status_processed'
  STATUS_FAILED    = 'status_failed'
  STATUSES         = [ STATUS_PENDING, STATUS_PROCESSED, STATUS_FAILED ]
  field :status, default: STATUS_PENDING
  scope :pending, ->{ where( status: STATUS_PENDING ) }
  scope :failed,  ->{ where( status: STATUS_FAILED  ) }

  field :bucket # 'ish-ses' (current), 'ish-ses-2024'
  field :format, type: String, default: 'raw' ## or 'json'

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

  def do_process_json
    stub = self
    @client ||= Aws::S3::Client.new(::SES_S3_CREDENTIALS)

    json = JSON.parse( @client.get_object( bucket: stub.bucket, key: stub.object_key ).body.read )
    subject = json['subject']
    message_id = json['message_id']

    ## Conversation
    if json['in_reply_to']
      in_reply_to_msg = WcoEmail::Message.where({ message_id: json['in_reply_to'] }).first
      if !in_reply_to_msg
        @conv = WcoEmail::Conversation.find_or_create_by({
          subject: subject,
        })
        in_reply_to_msg = WcoEmail::Message.find_or_create_by({
          message_id: json['in_reply_to'],
          conversation: @conv,
        })
      end
      @conv = in_reply_to_msg.conversation
    else
      @conv = WcoEmail::Conversation.unscoped.find_or_create_by({
        subject: subject,
      })
    end

    ## Lead, Leadset
    from       = json['from'][/<([^>]+)>/, 1].downcase rescue json['mail_from']
    mail_from  = json['mail_from']
    @lead      = Wco::Lead.find_or_create_by_email( from )
    @conv.leads.push @lead
    @conv.leadsets.push @lead.leadset

    ## message
    old_message   = WcoEmail::Message.unscoped.where( message_id: message_id ).first
    old_message.destroy! if old_message
    @message = WcoEmail::Message.create!({
      stub:         stub,
      conversation: @conv,
      lead:         @lead,

      message_id:     message_id,
      in_reply_to_id: json['in_reply_to'],
      object_key:     stub.object_key,

      subject: subject,
      date:    json['date'].to_s,

      from:      from,
      mail_from: mail_from,
      spam_status: json['spam_status'],
      to:   json['to'],
      cc:   json['cc'],

      part_html: json['html_body'],
      part_txt:  json['plain_body'],
    })

    ## Attachments
    json['attachments'].each do |att|
      @message.save_attachment_postal( att )
    end

    @conv.update_attributes({
      status:      WcoEmail::Conversation::STATUS_UNREAD,
      latest_at:   json['date'].to_time.to_s || Time.now.to_datetime,
      from_emails: ( @conv.from_emails + [ from ]).uniq,
      preview:     @message.preview_str,
    })

    ## tags
    @conv.tags.push Wco::Tag.inbox
    @conv.tags.push stub.tags
    @conv.save


    ## Actions & Filters
    email_filters = WcoEmail::EmailFilter.all.active.includes(:conditions)
    email_filters.each do |filter|
      reason = nil

      filter.conditions.each do |cond|
        reason ||= cond.apply(lead: @lead, message: @message )
      end

      if reason
        puts! "Applying2 filter #{filter} to conv #{@message.conversation} for matching #{reason}" if DEBUG

        ## skip
        skip_reason = nil

        filter.skip_conditions.each do |scond|
          skip_reason ||= scond.apply(lead: @lead, message: @message )
        end

        if skip_reason
          puts! "NOT Applying2 filter #{filter} to conv #{@message.conversation} for matching #{skip_reason}" if DEBUG
        else
          @conv.filters << filter
          @conv.save
          filter.actions.each do |action|
            @message.apply_filter_action( action )
          end
        end
      end
    end

    if 'Spam' == json['spam_status']
      @conv.tags.push Wco::Tag.spam
      @conv.tags -= [ Wco::Tag.inbox ]
    end

    stub.update_attributes({ status: WcoEmail::MessageStub::STATUS_PROCESSED })

    ## Notification
    ## _TODO
  end



end
