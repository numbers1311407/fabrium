Rails.application.routes.draw do
  root 'ng#index'
  resources :fabrics
  resources :fabric_variants
end
