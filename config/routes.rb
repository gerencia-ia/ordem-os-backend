Rails.application.routes.draw do
  root to: redirect("/api-docs")
  get "up" => "rails/health#show", as: :rails_health_check

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"

  namespace :api do
    namespace :v1 do
      resources :clientes
      resources :equipamentos do
        member do
          get :historico_laudos
        end
      end
      resources :servicos
      resources :materiais
      resources :users
      resources :categorias_servico
      resources :status
      resources :ordem_servicos do
        member do
          patch :update_status
          patch "equipamentos/:equipamento_id/laudo", to: "ordem_servicos#update_laudo"
          post "servicos", to: "ordem_servicos#add_servico"
          delete "servicos/:servico_id", to: "ordem_servicos#remove_servico"
          post "materiais", to: "ordem_servicos#add_material"
          delete "materiais/:material_id", to: "ordem_servicos#remove_material"
          post "tecnicos", to: "ordem_servicos#add_tecnico"
          delete "tecnicos/:user_id", to: "ordem_servicos#remove_tecnico"
        end
      end
      resources :prioridades
      resources :roles
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

      # Defines the root path route ("/")
    end
  end
end
