
Wco::Engine.routes.draw do
  root to: 'application#home'

  get 'application/tinymce', to: 'application#tinymce'

  resources :assets
  # get 'assets/:id', to: 'assets#show', as: :asset

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

  get 'leads/:id',     to: 'leads#show', id: /[^\/]+/
  post 'leads/bulkop', to: 'leads#bulkop'
  post 'leads/import', to: 'leads#import', as: :leads_import
  resources :leads
  resources :leadsets
  delete 'logs/bulkop', to: 'logs#bulkop', as: :logs_bulkop
  resources :logs

  post 'office_action_templates', to: 'office_action_templates#update'
  resources :office_action_templates
  resources :office_actions

  resources :prices
  resources :products
  resources :profiles
  post 'publishers/:id/do-run', to: 'publishers#do_run', as: :run_publisher
  resources :publishers
  resources :photos

  get 'reports/deleted', to: 'reports#index', as: :deleted_reports, defaults: { deleted: true }
  resources :reports

  resources :sites
  resources :subscriptions

  resources :tags

  resources :videos

end
