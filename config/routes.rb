Rails.application.routes.draw do
  root to: 'home#index'

  resources :datasets, :path => "dataset", only: :show
end
