Rails.application.routes.draw do
 
 namespace :api do
    namespace :v1 do
      resources :clientes
      resources :equipamentos
      resources :servicos
      resources :status
      resources :tecnicos
        resources :ordem_servicos do
          member do
            patch :update_status
          end
        end
      resources :prioridades

      post 'login', to: 'sessions#create'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: redirect('/api-docs')
    end
  end
end
