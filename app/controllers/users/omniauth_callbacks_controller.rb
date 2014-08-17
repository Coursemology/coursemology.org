class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # If a user is signed in then he is trying to link a new account
    if user_signed_in?
      auth = request.env["omniauth.auth"]
      if current_user && current_user.persisted? && current_user.update_external_account(auth)
        flash[:success] = "Your facebook account has been linked to this user account successfully."
      else
        flash[:error] = "The Facebook account has been linked with another user."
      end
      redirect_to edit_user_path(current_user)
    else
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
      if @user.persisted?
        # save fb access token in the session
        session[:fb_access_token] = request.env["omniauth.auth"]["credentials"]["token"]
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end
end
