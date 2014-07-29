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

  resources :tags
  resources :materials
  resources :categories
  resources :dye_methods
  resources :favorites

  root 'ng#index'
end
