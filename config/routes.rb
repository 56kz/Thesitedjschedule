Rails.application.routes.draw do
  devise_for :students, skip: [:registrations]
  get 'mi_cuenta/cambiar_contrasena', to: 'my_passwords#edit', as: :edit_my_password
  patch 'mi_cuenta/cambiar_contrasena', to: 'my_passwords#update'

  root 'rooms#index'
  resources :reservations
  # resources :schedules
  resources :rooms do
    resources :schedules
  end
  resources :suscriptions
  resources :users do
    member do
      get :edit_password
      patch :update_password
      post :send_reset_password_instructions
    end
  end
end
