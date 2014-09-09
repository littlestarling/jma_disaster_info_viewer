Rails.application.routes.draw do
  root to: 'feeds#index'
  resources 'feeds'
  post '/jmx' => 'feeds#create', as: :feeds_create
end
