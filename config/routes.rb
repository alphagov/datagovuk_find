Rails.application.routes.draw do
  root to: 'home#index'

  scope module: 'pages' do
    get 'terms'
    get 'privacy'
    get 'cookies'
    get 'support'
  end

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'

  get 'dataset/:uuid/:name', to: 'datasets#show', as: 'dataset'

  get 'use-of-data', to: 'consents#new', as: 'new_consent'
  get 'use-of-data/confirm', to: 'consents#confirm'

  get 'not_authenticated', to: 'errors#not_authenticated'

  get 'dataset/:dataset_uuid/:name/datafile/:datafile_uuid/preview', to: 'previews#show', as: 'datafile_preview'
end
