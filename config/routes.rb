Rails.application.routes.draw do
  root to: 'home#index'

  resources :dataset do
    get 'dataset/1234', to: 'dataset#show'
  end
end
