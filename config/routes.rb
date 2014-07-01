Rails.application.routes.draw do
  root 'static#index'
  resources :fabrics
  resources :fabric_variants
end
