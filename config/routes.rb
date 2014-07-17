Rails.application.routes.draw do
  devise_for :users

  resources :fabrics
  resources :mills
  resources :fabric_variants
  resources :properties

  scope 'data', format: true, constraints: { format: 'json' }, defaults: { format: 'json' } do
    get "keywords", to: "properties#keywords", as: :keywords_json
    get "categories", to: "properties#categories", as: :categories_json
    get "dye_methods", to: "properties#dye_methods", as: :dye_methods_json
  end

  root 'ng#index'
end
