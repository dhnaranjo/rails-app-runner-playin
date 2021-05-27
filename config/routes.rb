Rails.application.routes.draw do
  resources :pages, only: :index

  root controller: :pages, action: :index
end
