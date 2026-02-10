Rails.application.routes.draw do
  post "/signup", to: "users#create"
  get "/links/stats", to: "links_stats#index"
  resources :links, only: [:create]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /_internal/up that returns 200 if the app boots
  # with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "_internal/up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "/:slug", to: "redirects#show"
end
