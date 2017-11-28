Rails.application.routes.draw do
  root to: 'home#index'

  scope module: 'pages' do
    get 'accessibility'
    get 'cookies'
    get 'privacy'
    get 'support'
    get 'terms'
  end

  match "404", to: "errors#not_found", via: :all
  match "500", to: "errors#internal_server_error", via: :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'

  get 'dataset/:uuid/:name', to: 'datasets#show', as: 'dataset'

  get 'use-of-data', to: 'consents#new', as: 'new_consent'
  get 'use-of-data/confirm', to: 'consents#confirm'

  get 'not_authenticated', to: 'errors#not_authenticated'

  get 'support', to: 'support#support'
  get 'support/submit', to: 'support#submit'
  get 'support/confirmation', to: 'support#confirmation'
  post 'support/ticket', to: 'support#ticket'

  get 'dataset/:dataset_uuid/:name/datafile/:datafile_uuid/preview', to: 'previews#show', as: 'datafile_preview'
end
