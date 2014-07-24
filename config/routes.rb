Rails.application.routes.draw do
  devise_for :users

  resources :fabrics
  resources :fabric_variants, except: [:index] do
    collection do
      get 'preview', as: :preview
      post 'preview'
    end
  end
  resources :mills
  resources :properties

  scope 'props', format: true, constraints: { format: 'json' }, defaults: { format: 'json' } do
    get "keywords", to: "properties#keywords", as: :keywords_json
    get "categories", to: "properties#categories", as: :categories_json
    get "dye_methods", to: "properties#dye_methods", as: :dye_methods_json
  end

  root 'ng#index'
end
