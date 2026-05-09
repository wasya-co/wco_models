
Wco::Engine.routes.draw do
  root to: 'application#home'

  namespace :api do
    get 'leads/index_hash', to: 'leads#index_hash'

    get 'obf',              to: 'obfuscated_redirects#show' ## testing only.
    get 'obf/:id',          to: 'obfuscared_redirects#show'

    post  'reports',                to: 'reports#create'
    patch 'reports/:id/add-config', to: 'reports#add_config'
    get   'newspartials/:id/config',     to: 'newspartials#show_config', as: :newspartial_config

    match 'newsvideos/:id/generate-illustration', to: 'newsvideos#generate_illustration', as: :newsvideo_generate_illustration, via: [ :get, :post ]

    get 'tags', to: 'tags#index'

    post 'videos', to: 'videos#create'
  end

  get 'application/tinymce',       to: 'application#tinymce'
  get 'linkedin_sync', to: 'application#linkedin_sync', as: :linkedin_sync
  match 'linkedin_cb',   to: 'application#linkedin_cb',   as: :linkedin_cb, via: [ :post, :get ]

  resources :assets
  # get 'assets/:id', to: 'assets#show', as: :asset

  post 'galleries/update', to: 'galleries#update_many', as: :update_galleries
  resources :galleries do
    post 'multiadd', :to => 'photos#j_create', :as => :multiadd
  end

  resources :headlines

  post 'invoices/send/:id',         to: 'invoices#email_send',         as: :send_invoice
  post 'invoices/cr-m/:leadset_id', to: 'invoices#create_monthly_pdf', as: :create_monthly_invoice_for_leadset
  post 'invoices/create-pdf',       to: 'invoices#create_pdf',         as: :create_invoice_pdf
  post 'invoices/create-stripe',    to: 'invoices#create_stripe',      as: :create_invoice_stripe
  get  'invoices/new_pdf',          to: 'invoices#new_pdf',            as: :new_invoice_pdf
  get  'invoices/new_stripe',       to: 'invoices#new_stripe',         as: :new_invoice_stripe
  post 'invoices/:id/send-stripe',  to: 'invoices#send_stripe',        as: :send_invoice_stripe
  resources :invoices

  get  'leads/new',    to: 'leads#new'
  get  'leads/import', to: 'leads#new_import', as: :new_leads
  post 'leads/import', to: 'leads#create_import'
  post 'leads/bulkop', to: 'leads#bulkop'
  get  'leads/:id',    to: 'leads#show', id: /[^\/]+/
  resources :leads
  resources :leadsets
  delete 'logs/bulkop', to: 'logs#bulkop', as: :logs_bulkop
  resources :logs

  resources :newsoverlay_configs
  resources :newsoverlays

  match 'newspartials/:id/generate-speech', to: 'newspartials#generate_speech', as: :newspartial_generate_speech, via: [ :get, :post ]
  match 'newspartials/:id/generate-video',  to: 'newspartials#generate_video',  as: :newspartial_generate_video,  via: [ :get, :post ]
  resources :newspartials

  match 'newsvideos/:id/generate-illustration', to: 'newsvideos#generate_illustration', as: :newsvideo_generate_illustration, via: [ :get, :post ]
  post  'newsvideos/:id/generate', to: 'newsvideos#generate', as: :generate_newsvideo
  post  'newsvideos/:id/split',    to: 'newsvideos#split',    as: :split_newsvideo
  resources :newsvideos

  resources :obfuscated_redirects

  post 'office_action_templates',         to: 'office_action_templates#update'
  post 'office_action_templates/perform', to: 'office_action_templates#perform', as: :oat_perform_with_conversations ## from the mailbox, the oat_id is passed as a body param.
  post 'office_action_templates/:id/perform', to: 'office_action_templates#perform', as: :oat_perform
  get  'office_action_templates/:id/perform', to: 'office_action_templates#perform'
  resources :office_action_templates

  post 'office_actions/:id/run', to: 'office_actions#do_run', as: :run_office_action
  get  'office_actions/active', to: 'office_actions#index', defaults: { status: 'active' }, as: :active_office_actions
  resources :office_actions

  resources :prices
  resources :products
  resources :profiles
  post 'publishers/:id/do-run', to: 'publishers#do_run',     as: :run_publisher
  post 'publishers/do-run',     to: 'publishers#do_run_any', as: :run_any_publisher
  resources :publishers

  post   'photos/update-ordering', to: 'galleries#update_ordering', as: :update_ordering_photos
  post   'photos/move',   to: 'photos#move',    as: :move_photos
  delete 'photos/delete', to: 'photos#destroy', as: :delete_photos
  resources :photos

  get 'reports',         to: 'reports#index',  as: :reports, defaults: { deleted: false }
  get 'reports/deleted', to: 'reports#index',  as: :deleted_reports, defaults: { deleted: true } ## must be before resources, because 'deleted' is not an id.
  match 'reports/:id/to-linkedin', to: 'reports#to_linkedin', as: :report_to_linkedin, via: [ :get, :post ]
  match 'reports/:id/to-facebook', to: 'reports#to_facebook', as: :report_to_facebook, via: [ :get, :post ]
  match 'reports/:id/to-company-linkedin', to: 'reports#to_company_linkedin', as: :report_to_company_linkedin, via: [ :get, :post ]
  resources :reports

  post 'sites/:id/check_sitemap', to: 'sites#check_sitemap', as: :check_sitemap
  resources :sites
  get  'sitemap_paths/:id/check', to: 'sitemap_paths#check', as: :check_spath
  post 'sitemap_paths/:id/clear', to: 'sitemap_paths#clear', as: :clear_spath
  resources :sitemap_paths, as: :spaths
  resources :subscriptions

  ## only one resource
  delete 'tags/remove/:id/from/:resource/:resource_id', to: 'tags#remove_from', as: :remove_tag_from
  post   'tags/add-to/:resource/:resource_id', to: 'tags#add_to', as: :add_tag_to
  ## many resources
  post   'tags/add-to-many/:resource',  to: 'tags#add_to_many',  as: :add_tag_to_many
  post   'tags/rm-from-many/:resource', to: 'tags#rm_from_many', as: :rm_tag_from_many
  resources :tags

  ## In order to have unsubscribes_url , unsubscribes must be in wco .
  get  'unsubscribes/analytics',            to: 'unsubscribes#analytics'
  get  'api/unsubscribes/by-token/:token',  to: 'unsubscribes#new', as: :unsubscribe_by_token
  post 'api/unsubscribes/by-token/:token',  to: 'unsubscribes#do_unsubscribe'
  resources :unsubscribes

  resources :videos

end
