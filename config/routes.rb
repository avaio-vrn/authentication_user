# -*- encoding : utf-8 -*-
AuthenticationUser::Engine.routes.draw do
  resources :basket_items, only: [:create, :update, :destroy]
  resources :baskets, only: [:index, :show, :destroy] do
    get :info, on: :member
    get :registration, on: :member
    post :thanks, on: :member
    # post 'change_status/:status', on: :member, to: 'baskets#change_status', as: :change_status
    get :send_order, on: :collection
    get :list, on: :collection
    get :report, on: :collection
  end

  get 'registration', to: 'users#new', as: :registration
  get 'login', to: 'user_sessions#new', as: :login
  get 'login_ynd', to: 'user_sessions#new', as: :login_ynd, defaults: { provider: 'yandex' }
  get 'login_mail', to: 'user_sessions#new', as: :login_mail, defaults: { provider: 'mailru' }
  get 'logout', to: 'user_sessions#destroy', as: :logout
  resources :users do
    get :activate, on: :member
    post :create_from_cart, on: :collection
  end
  get 'edit_password_reset/:id', to: 'password_resets#edit'

  post "oauth/callback", to: "oauths#callback"
  get "oauth/callback", to: "oauths#callback"
  get "oauth/:provider", to: "oauths#oauth", as: :auth_at_provider

  resources :password_resets, expect: [:index, :show, :delete]
  resources :user_sessions
end
