class ApplicationController < ActionController::API
  before_action :set_q
  before_action :authenticate_request
  attr_reader :current_user

  protected

  def set_q
    @filter = JSON.parse params.fetch(:filter, '{}') rescue nil
    @filter ||= {}
  end

  private

  def authenticate_request
    command = AuthorizeApiRequest.call(request.headers)
    if command.success?
      @current_user = command.result
    else
      render json: command.errors, status: :unauthorized
    end
  end
end
