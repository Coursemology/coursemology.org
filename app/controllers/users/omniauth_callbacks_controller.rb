class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # If a user is signed in then he is trying to link a new account
    if user_signed_in?
      if authentication.persisted? # This was a linking operation so send back the user to the account edit page
        flash[:success] = I18n.t "controllers.omniauth_callbacks.process_callback.success.link_account",
                                :provider => registration_hash[:provider].capitalize,
                                :account => registration_hash[:email]
      else
        flash[:error] = I18n.t "controllers.omniauth_callbacks.process_callback.error.link_account",
                               :provider => registration_hash[:provider].capitalize,
                               :account => registration_hash[:email],
                               :errors =>authentication.errors
      end
      redirect_to edit_user_account_path(current_user)
    else
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end
end
