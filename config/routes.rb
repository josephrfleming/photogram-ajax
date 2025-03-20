Rails.application.routes.draw do
  root "users#feed"

  devise_for :users

  resources :comments
  resources :follow_requests, except: [:index, :show, :new, :edit]
  resources :likes, only: [:create, :destroy]
  resources :photos, except: [:index]
  resources :users, only: [:index]

  get ":username"       => "users#show",    as: :user
  get ":username/liked" => "users#liked",   as: :liked
  get ":username/feed"  => "users#feed",    as: :feed
  get ":username/discover" => "users#discover", as: :discover

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
