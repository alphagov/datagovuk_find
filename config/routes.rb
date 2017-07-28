Rails.application.routes.draw do
  get 'search/', to: 'search#search'
  root to: 'home#index'

  resources :datasets, :path => "dataset", only: :show
end
