Rails.application.configure do
  smtp_config = config_for(:smtp)
  config.x.smtp.address = smtp_config['address']
  config.x.smtp.port = smtp_config['port']
  config.x.smtp.user_name = smtp_config['user_name']
  config.x.smtp.password = smtp_config['password']
  config.x.smtp.authentication = smtp_config['authentication']
  config.x.smtp.domain = smtp_config['domain']

  if Rails.env.staging? || Rails.env.production?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: Rails.configuration.x.smtp.address,
      port: Rails.configuration.x.smtp.port,
      user_name: Rails.configuration.x.smtp.user_name,
      password: Rails.configuration.x.smtp.password,
      authentication: Rails.configuration.x.smtp.authentication || 'cram_md5',
      domain: Rails.configuration.x.smtp.domain
    }
  end
end
