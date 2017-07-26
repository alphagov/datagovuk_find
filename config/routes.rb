Rails.application.routes.draw do
  get 'search/index'

  root to: 'home#index'

  resources :datasets, :path => "dataset", only: :show
end
