class GenerateToken
  prepend SimpleCommand

  def initialize(email)
    @email = email
  end

  def call
    @token = JsonWebToken.encode(user_id: user.id) if user

    save_token if @token

    return @token
  end

  private

  attr_accessor :email, :token

  def user
    user = User.find_by_email(email)
    return user if user

    errors.add :user_authentication, I18n.t('messages.invalid_login')
    nil
  end

  def save_token
    current_user = user
    current_user.token = @token
    if current_user.save
      TokenExpirationJob.set(wait: 1.hours).perform_later(current_user)
    end
  end
end
