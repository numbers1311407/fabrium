Rails.application.routes.draw do
  devise_for :users

  resources :fabrics
  resources :fabric_variants
  resources :properties

  scope format: true, constraints: { format: 'json' } do
    get "keywords", to: "properties#keywords"
  end

  root 'ng#index'
end
