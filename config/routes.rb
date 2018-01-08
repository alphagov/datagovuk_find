Rails.application.routes.draw do
  root to: 'home#index'

  scope module: 'legacy' do
    get 'dataset/:legacy_name', to: 'datasets#redirect'
    get 'data/search',          to: 'search#redirect'
    get 'contact',              to: redirect('support')
  end

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

  resources :tickets, only: [:new, :create]
  get 'tickets/confirmation', to: 'tickets#confirmation'

  get 'dataset/:dataset_uuid/:name/datafile/:datafile_uuid/preview', to: 'previews#show', as: 'datafile_preview'
end
