Rails.application.routes.draw do

  devise_for :students
  root 'rooms#index'
  resources :reservations
  # resources :schedules
  resources :rooms do
    resources :schedules
  end
  resources :suscriptions
  resources :users
end
