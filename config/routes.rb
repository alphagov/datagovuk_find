Rails.application.routes.draw do
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'
  resources :datasets, :path => "dataset", param: :name, only: :show
  get 'file/:file_id/preview', to: 'datasets#preview', as: :file_preview

  root to: 'home#index'
  get '/use-of-data', to: 'home#consent'
  get 'confirm_consent', to: 'home#confirm_consent'
  get 'not_authenticated', to: 'errors#not_authenticated'
end
