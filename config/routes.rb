Rails.application.routes.draw do
  root 'ng#index'

  resources :fabrics
  resources :fabric_variants
  resources :properties

  scope format: true, constraints: { format: 'json' } do
    get "keywords", to: "properties#keywords"
  end
end
