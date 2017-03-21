Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'access#menu'

  get 'admin', :to => 'access#menu'
  get 'access/menu'
  get 'access/login'
  post 'access/attempt_login'
  get 'access/logout'
  get 'programs/score', :to => 'programs#score'

  resources :admin_users do
     member do
      get :delete
     end
  end

  resources :programs do
     member do
      get :delete
     end
  end

  resources :lines, :only => [:edit,:update]

  resources :tests, :only => [:index,:edit,:update]

end
