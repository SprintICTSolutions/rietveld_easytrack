class TokenExpirationJob < ApplicationJob

  def perform(user)
    user.token = "expired"
    user.save!
  end

end
