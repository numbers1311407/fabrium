Rails.application.routes.draw do
  devise_for :users

  resources :fabrics
  resources :fabric_variants do
    collection do
      get 'preview', as: :preview
      post 'preview'
    end
  end

  resources :mills

  resource :profile

  resources :tags
  resources :materials
  resources :categories
  resources :dye_methods
  resources :favorites

  resources :carts do
    get :cart
  end

  # Templates.
  # These should probably be static and handle all logic client side 
  # but... they use some form helpers and contextual chunks based on
  # user roles.
  get "/templates/*path", to: 'ng#template'

  root 'ng#index'
end
