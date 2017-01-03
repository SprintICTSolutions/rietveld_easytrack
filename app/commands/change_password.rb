class ChangePassword
  prepend SimpleCommand

  def initialize(email, token, password)
    @email = email
    @token = token
    @password = password
  end

  def call
    change_password if user
  end

  private

  attr_accessor :email, :token, :password

  def user
    user = User.find_by_email(email)
    return user if user && user.token == @token

    errors.add :change_password, I18n.t('errors.messages.invalid')
    nil
  end

  def change_password
    cur_user = user
    cur_user.password = @password
    cur_user.token = nil
    if !cur_user.save
      errors.add :change_password, I18n.t('errors.messages.not_saved')
    end
  end
end
