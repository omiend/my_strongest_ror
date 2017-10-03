Rails.application.routes.draw do

  root "pages#index"

  # Account(users)
  devise_for :users

  # Employees
  resources :employees

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end
