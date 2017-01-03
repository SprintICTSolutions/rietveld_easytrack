class LostPasswordMailer < ApplicationMailer

  def password_email(email, token)

    @subject = I18n.t('email.lost_password_subject')
    @token = token
    @email = email

    mail(to: @email, subject: @subject)
  end
end
