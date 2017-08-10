Rails.application.routes.draw do
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'search/', to: 'search#search'
  get 'search/tips', to: 'search#tips'
  root to: 'home#index'

  resources :datasets, :path => "dataset", param: :name, only: :show
end
