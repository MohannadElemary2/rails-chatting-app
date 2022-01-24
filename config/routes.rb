Rails.application.routes.draw do
  resources :application do
    resources :chat do
      resources :message
    end
  end
end
