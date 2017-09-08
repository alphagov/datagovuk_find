Rails.application.routes.draw do
  root to: 'home#index'

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'
  resources :datasets, :path => "dataset", param: :name, only: :show

  get 'use-of-data', to: 'consents#new'
  get 'use-of-data/confirm', to: 'consents#confirm'

  get 'not_authenticated', to: 'errors#not_authenticated'

  resources :datasets, path: "dataset", param: :name, only: :show
end
