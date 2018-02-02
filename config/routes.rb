Rails.application.routes.draw do
  root to: 'home#index'

  scope module: 'legacy' do
    get 'dataset/:legacy_name', to: 'datasets#redirect'
    get 'dataset/:legacy_dataset_name/resource/:datafile_uuid', to: 'datafiles#redirect'
    get 'data/search',          to: 'search#redirect'
    get 'contact',              to: redirect('support')
    get 'cookies-policy',       to: redirect('cookies')
  end

  scope module: 'pages' do
    get 'about'
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

  get 'use-of-data', to: 'consents#new', as: 'new_consent'
  get 'use-of-data/confirm', to: 'consents#confirm'

  get 'not_authenticated', to: 'errors#not_authenticated'

  resources :tickets, only: [:new, :create]
  get 'tickets/confirmation', to: 'tickets#confirmation'

  get 'dataset/:short_id/:name', to: 'datasets#show', as: 'dataset'
  get 'dataset/:dataset_short_id/:name/datafile/:datafile_short_id/preview', to: 'previews#show', as: 'datafile_preview'
end
