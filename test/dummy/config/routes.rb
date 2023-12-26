
Rails.application.routes.draw do
  root to: 'application#home'

  mount Wco::Engine => "/wco"
end
