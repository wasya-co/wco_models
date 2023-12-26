
Wco::Engine.routes.draw do
  root to: 'application#home'

  resources :prices
  resources :products

  resources :subscriptions

end
