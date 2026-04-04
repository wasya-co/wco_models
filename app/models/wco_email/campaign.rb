
##
## Sends a campaign.
## _vp_ 2023-02-02
##
class WcoEmail::Campaign
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  store_in collection: 'ish_email_campaigns'

  # field :slug
  # validates_uniqueness_of :slug, allow_nil: true

  PAGE_PARAM_NAME = 'email_campaigns_page'

  belongs_to :email_template
  def tmpl; email_template; end

  belongs_to :active_tag, class_name: 'Wco::Tag'
  belongs_to :inactive_tag, class_name: 'Wco::Tag'

  # field :active_tag_slug
  # field :inactive_tag_slug

  field :status
  field :sent_at, type: :time

  # field :subject
  # field :body

  # field :sent_at, type: DateTime
  # field :send_at, type: DateTime

  ## not really. a template may have unsubscribes?
  # has_many :unsubscribes, class_name: 'WcoEmail::Unsubscribe', inverse_of: :campaign
  # has_and_belongs_to_many :leads, class_name: 'Wco::Lead'

  ## For tracking
  attr_reader :tid

  def do_send
    active_tag.leads.each do |lead|
      ctx = Ctx.create!({
        email_template: tmpl,
        lead:           lead,
        send_at:        Time.now,
      })
      lead.tags.push inactive_tag
      lead.tags.delete active_tag
      lead.save
    end
  end

  def self.list
    [[nil,nil]] + all.map { |p| [ p.slug, p.id ] }
  end

end
