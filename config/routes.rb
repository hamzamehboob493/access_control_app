Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # User registration
  get "/signup", to: "users#new", as: "new_user_registration"
  post "/signup", to: "users#create", as: "signup"
  resources :users, only: [ :show, :edit, :update ]

  # Age verification
  get "/age-verification", to: "age_verification#show", as: :age_verification
  patch "/age-verification", to: "age_verification#update"

  # Parental consent
  resources :parental_consents, only: [ :show, :new, :create, :edit, :update ]
  get "/parental-consent/verify/:token", to: "parental_consents#verify", as: :verify_parental_consent

  # Public invitation acceptance
  get "/invitations/:token", to: "invitations#show", as: :invitation
  post "/invitations/:token", to: "invitations#accept", as: :accept_invitation

  # Organizations
  resources :organizations do
    member do
      get :analytics
    end

    resources :organization_memberships, only: [ :index, :show, :new, :create, :update, :destroy ] do
      collection do
        post :invite
      end
      member do
        patch :approve
        patch :reject
        patch :suspend
        patch :reactivate
        post :re_invite
      end
    end
    resources :participation_spaces
  end

  # Age groups (admin only)
  resources :age_groups, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # Admin routes
  namespace :admin do
    resources :organizations, only: [ :index, :show, :update ] do
      member do
        patch :verify
      end
    end
    resources :users, only: [ :index, :show, :update ]
    resources :analytics, only: [ :index ]
  end

  # API routes for AJAX requests
  namespace :api do
    namespace :v1 do
      resources :organizations, only: [ :index, :show ] do
        resources :analytics, only: [ :index ]
      end
    end
  end

  # Root route
  root "dashboard#index"
end
