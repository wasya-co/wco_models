
class WcoEmail::Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in collection: 'office_email_conversations'

  PAGE_PARAM_NAME = 'conv_page'

  STATUS_UNREAD = 'status_unread'
  STATUS_READ   = 'status_read'
  STATUSES      = [ STATUS_UNREAD, STATUS_READ ]
  field :status
  scope :unread, ->{ where( status: WcoEmail::Conversation::STATUS_UNREAD ) }
  def unread?
    status == STATUS_UNREAD
  end

  field :subject
  index({ subject: -1 })

  field :latest_at, type: Time
  index({ latest_at: -1 })

  field :deleted_at, type: Time ## just in case... should be unused. _vp_ 2026-07-19

  field :from_emails, type: :array, default: []
  index({ from_emails: -1 })

  field :preview, default: ''

  has_many :messages,             class_name: '::WcoEmail::Message'

  has_and_belongs_to_many :tags,     class_name: 'Wco::Tag',     index: true
  has_and_belongs_to_many :leadsets, class_name: 'Wco::Leadset', index: true
  has_and_belongs_to_many :leads,    class_name: 'Wco::Lead',    index: true
  has_and_belongs_to_many :filters,  class_name: 'WcoEmail::EmailFilter', index: true

=begin
  current_profile = OpenStruct.new per_page: 25
  params = { tagname: 'inbox' }
=end
  def self.load_conversations_messages_tag_by_params_and_profile params, current_profile
    @conversations = WcoEmail::Conversation.all

    if params[:tagname]
      @tag = Wco::Tag.find_by slug: params[:tagname]
      @conversations = @conversations.where( :tag_ids.in => [ @tag.id ] )
    end
    if params[:tagname_not]
      @tag_not = Wco::Tag.find_by slug: params[:tagname_not]
      @conversations = @conversations.where( :tag_ids.nin => [ @tag_not.id ] )
    end

    if params[:subject].present?
      @conversations = @conversations.where({ subject: /.*#{params[:subject]}.*/i })
    end

    if params[:from_email].present?
      @conversations = @conversations.where({ from_emails: /.*#{params[:from_email]}.*/i })
    end

    if params[:lead_id].present?
      @conversations = @conversations.where( lead_ids: params[:lead_id] )
    end

    @conversations = @conversations.where(
      ).includes(
        :leads,
        # :messages,
        :tags
      ).order_by( latest_at: :desc
      ).page( params[:conv_page] ).per( current_profile.per_page )

    conversation_ids = @conversations.map &:id
    messages = WcoEmail::Message.where(
      :conversation_id.in => conversation_ids,
      read_at: nil,
    )
    @messages_hash = {}
    messages.map do |msg|
      @messages_hash[msg.id.to_s] = msg
    end

    return [ @conversations, @messages_hash, @tag ]
  end

  def cache_key
    "#{self.class.name} #{id.to_s} #{updated_at}"
  end

  def to_s
    "#{subject} (#{messages.length})"
  end
end
Conv = WcoEmail::Conversation
