Rails.application.routes.draw do
  mount IshModels::Engine => "/ish_models"
end
