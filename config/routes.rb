Rails.application.routes.draw do
 
 namespace :api do
    namespace :v1 do
      resources :clientes
      resources :equipamentos do
        member do
          get :historico_laudos
        end
      end
      resources :servicos
      resources :categorias_servico
      resources :status
      resources :tecnicos
        resources :ordem_servicos do
          member do
            patch :update_status
            patch 'equipamentos/:equipamento_id/laudo', to: 'ordem_servicos#update_laudo'
            post 'servicos', to: 'ordem_servicos#add_servico'
            delete 'servicos/:servico_id', to: 'ordem_servicos#remove_servico'
            post 'tecnicos', to: 'ordem_servicos#add_tecnico'
            delete 'tecnicos/:tecnico_id', to: 'ordem_servicos#remove_tecnico'
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
