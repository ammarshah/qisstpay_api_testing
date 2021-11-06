Rails.application.routes.draw do
  root to: "orders#index"
  
  resources :orders, only: [:index, :show, :new, :create] do
    collection do
      post 'callback'
    end
  end
end
