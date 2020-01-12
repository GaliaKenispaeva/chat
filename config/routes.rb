Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    get    '/two_factor' => 'two_factors#show', as: 'admin_two_factor'
    post   '/two_factor' => 'two_factors#create'
    delete '/two_factor' => 'two_factors#destroy'
  end
  
  root controller: :rooms, action: :index

  resources :room_messages
  resources :rooms
end
