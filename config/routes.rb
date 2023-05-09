# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect("/subscriptions")

  resource :site, except: :destroy
  resolve("Site") { [:site] }

  resource :merchant_account, only: :create
  resource :plan, only: %i[edit create]
  resolve("Plan") { [:plan] }

  resources :authorized_urls, only: :create

  resources :subscriptions, except: %i[create update] do
    get "confirm", to: :member
  end

  namespace :api do
    namespace :internal do
      resources :access_tokens, only: :create
      resource :posts, only: :show
      resources :subscriptions, only: :create
    end
    namespace :v1 do
      resource :posts, only: :create
    end
  end

  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end

  devise_for :users,
             path: "auth",
             controllers: {
               registrations: "users/registrations",
               sessions: "users/sessions",
             }

  devise_for :admins

  authenticate :admin do
    mount GoodJob::Engine => "good_job"
  end
end
