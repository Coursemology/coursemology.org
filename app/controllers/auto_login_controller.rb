class AutoLoginController < ApplicationController

  def auto_login_from_facebook
    @facebook_uid ||= Koala::Facebook::OAuth.new.get_user_info_from_cookies(cookies)
    @user = User.where(:provider => "facebook", :uid => @facebook_uid).first
    if @user && @user.persisted? && @user.is_logged_in?
      sign_in @user, :event => :authentication
    end
    respond_to do |format|
      format.json {render json: {status: "OK"}}
    end
  end
end