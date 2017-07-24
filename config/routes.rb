Rails.application.routes.draw do
  root to: 'home#index'

  resources :datasets do
    get 'dataset/:id', to: 'datasets#show'
  end
end
