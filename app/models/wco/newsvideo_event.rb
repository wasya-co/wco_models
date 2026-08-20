
class Wco::NewsvideoEvent
  include Mongoid::Document
  include Mongoid::Timestamps
  include Wco::Utils
  store_in collection: 'wco_newsvideo_events'

  PAGE_PARAM_NAME = 'newsvideo_events_page'

  belongs_to :newsvideo, class_name: 'Wco::Newsvideo', optional: true
  belongs_to :newspartial, class_name: 'Wco::Newspartial', optional: true

  field :start_at_ms, type: :integer, default: 0
  field :duration_ms, type: :integer, default: 0

  field :exec_js, type: :string, default: ''

  field :status, default: 'active'
  field :name, default: '<event>'

end
