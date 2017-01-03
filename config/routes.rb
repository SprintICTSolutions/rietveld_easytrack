Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Swagger
  resources :apidocs, only: [:index]
  get '/docs' => redirect("/swagger-ui/index.html?url=#{Rails.configuration.x.swagger.schemes[0]}://#{Rails.configuration.x.swagger.host}/apidocs")
  get '/images/:image.:extension' => redirect('/swagger-ui/images/%{image}.%{extension}')
  get '/lib/*path.js' => redirect('/swagger-ui/lib/%{path}.js')
  get '/css/:css.:extension' => redirect('/swagger-ui/css/%{css}.%{extension}')

  # Authentication
  post 'authenticate', to: 'authentication#login'
  post 'lost_password', to: 'authentication#lost_password'
  post 'change_password', to: 'authentication#change_password'
end
