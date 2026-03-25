Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :users, except: [ :destroy ] do
        member do
          patch :disable
          patch :update_theme
          patch :update_locale
        end
      end

      resources :games, except: [ :destroy ] do
        member do
          patch :disable
        end
      end

      resources :reviews, except: [ :new, :edit ]

      resources :users_playtimes, except: [ :new, :edit ]

      resources :links, except: [ :new, :edit ]

      resources :assets, except: [ :new, :edit ] do
        member do
          get :download
        end
      end

      resources :games, only: [] do
        resources :reviews, only: [ :index, :create ], param: :game_name
        resources :users_playtimes, only: [ :index, :create ], param: :game_name
        resources :links, only: [ :index, :create ], param: :game_name
        resources :assets, only: [ :index, :create ], param: :game_name
      end

      resources :users, only: [] do
        resources :reviews, only: [ :index ], param: :user_slug
        resources :users_playtimes, only: [ :index ], param: :user_slug
      end
    end
  end
end
