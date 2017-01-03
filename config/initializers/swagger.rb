Rails.application.configure do
  swagger_config = config_for(:swagger)
  config.x.swagger.host = swagger_config['host'] || 'localhost:3000'
  config.x.swagger.schemes = swagger_config['schemes'] || 'http'
  config.x.swagger.base_path = swagger_config['base_path'] || '/'
end
