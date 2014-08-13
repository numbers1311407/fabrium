Rails.application.routes.draw do
  devise_for :users, 
    path: 'accounts', 
    controllers: { 
      registrations: "registrations" 
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      sign_up: 'signup/:meta'
    }

  devise_scope :user do
    #redirect the normal signup to buyer
    get '/accounts/signup', to: redirect('/accounts/signup/buyer')
  end

  resources :fabrics

  resources :fabric_variants do
    collection do
      get 'preview', as: :preview
      post 'preview'
    end
  end

  resources :buyers

  resources :mills do
    member do
      get :edit_blocklist
      put :toggle_active
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

  scope :data, constraints: { format: :json } do
    get "test_item_number", to: "fabrics#test_item_number"
    get "country_subregions", to: "carmen#subregions", as: :country_subregions
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

  resources :carts, path: :hanger_requests, except: :edit do
    resources :cart_items, path: :items, except: [:index, :edit, :new]
  end

  # The "public" cart route, emailed to prospective buyers when mill's 
  # generate carts for them
  get '/carts/:public_id/pub', to: "carts#public_show", as: :public_cart

  # The singular "cart" routes, which map to cart resources as expected
  # but determine the cart id from the logged in user and their role
  get '/cart', to: "carts#pending_cart", as: :pending_cart
  delete '/cart/items/:id', to: "cart_items#destroy"
  post  '/cart/items', to: "cart_items#create"

  # Templates.
  # These should probably be static and handle all logic client side 
  # but... they use some form helpers and contextual chunks based on
  # user roles.
  get "/templates/*path", to: 'ng#template'

  root 'ng#index'
end
