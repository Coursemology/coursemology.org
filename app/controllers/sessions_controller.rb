class SessionsController < Devise::SessionsController

  def destroy
    current_user.is_logged_in = false if current_user
    super
  end
end