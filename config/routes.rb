Rails.application.routes.draw do

  root "pages#index"

  # Account(users)
  devise_for :users

  # Employees
  resources :employees

  # Avatar editing
  get    '/avatar/:id/edit',   to: 'employees#edit_avatar',   as: 'edit_avatar'
  patch  '/avatar/:id/update', to: 'employees#update_avatar', as: 'update_avatar'
  delete '/avatar/:id/delete', to: 'employees#delete_avatar', as: 'delete_avatar'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end
