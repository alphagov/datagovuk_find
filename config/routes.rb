Rails.application.routes.draw do
  root to: 'home#index'

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'

  resources :datasets, :path => "dataset", param: :name, only: :show

  get 'dataset/:uuid/:name', to: 'datasets#show'

  get 'use-of-data', to: 'consents#new', as: 'new_consent'
  get 'use-of-data/confirm', to: 'consents#confirm'

  get 'not_authenticated', to: 'errors#not_authenticated'

  get 'dataset/:name/preview/:uuid', to: 'datasets#preview', as: 'preview'
end
