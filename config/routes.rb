Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }

  resources :fabrics
  resources :fabric_variants do
    collection do
      get 'preview', as: :preview
      post 'preview'
    end
  end

  resources :mills do
    member do
      get :edit_blocklist
    end
  end

  resource :profile do
    get :blocklist
  end

  resources :users do
    member do 
      put :activate
    end
    collection do
      get :domains
      # get :mills
      # get :admins
    end
  end

  # simple editable redirect for the first controller hit by /lists,
  # which is a menu item with a subnav
  get "/lists", to: redirect("/tags")

  resources :admins
  resources :approved_domains
  resources :tags
  resources :materials
  resources :categories
  resources :dye_methods
  resources :favorites
  resources :fabric_notes, only: [:show, :update, :destroy]

  resources :carts, except: :edit do
    resources :cart_items, path: :items
  end
  get :cart, to: "carts#pending_cart"

  # Templates.
  # These should probably be static and handle all logic client side 
  # but... they use some form helpers and contextual chunks based on
  # user roles.
  get "/templates/*path", to: 'ng#template'

  root 'ng#index'
end
