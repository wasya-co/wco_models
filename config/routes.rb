
Wco::Engine.routes.draw do
  root to: 'application#home'

  get 'application/tinymce', to: 'application#tinymce'

  resources :assets
  # get 'assets/:id', to: 'assets#show', as: :asset

  resources :galleries do
    post 'multiadd', :to => 'photos#j_create', :as => :multiadd
  end

  get 'leads/:id',     to: 'leads#show', id: /[^\/]+/
  post 'leads/bulkop', to: 'leads#bulkop'
  post 'leads/import', to: 'leads#import', as: :leads_import
  resources :leads
  resources :leadsets

  resources :prices
  resources :products
  resources :profiles
  post 'publishers/:id/do-run', to: 'publishers#do_run', as: :do_run_publisher
  resources :publishers
  resources :photos

  resources :sites
  resources :subscriptions

  resources :tags

end
