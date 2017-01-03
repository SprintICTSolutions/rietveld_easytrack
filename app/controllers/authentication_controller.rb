class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      render json: { auth_token: command.result }
    else
      render json: command.errors, status: :unauthorized
    end
  end

  def lost_password
    command = GenerateToken.call(params[:email])

    if command.success?
      begin
        LostPasswordMailer.password_email(params[:email], command.result).deliver_now
      rescue => e
        Rails.logger.error "Vergeten wachtwoord e-mail to: '#{params[:email]}' not sent: #{e.message}"
      end
    else
      render json: command.errors, status: :unprocessable_entity
    end
  end

  def change_password
    command = ChangePassword.call(params[:email], params[:token], params[:password])

    if !command.success?
      render json: command.errors, status: :unprocessable_entity
    end
  end
end
