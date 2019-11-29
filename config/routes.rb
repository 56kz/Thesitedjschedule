Rails.application.routes.draw do
  resources :reservations
  # resources :schedules
  resources :rooms do
    resources :schedules
  end
  resources :suscriptions
  resources :users
end
