class AutoLoginController < ApplicationController

  def auto_login_from_facebook
    @facebook_uid ||= Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s).get_user_from_cookies(cookies)
    @user = User.where(:provider => "facebook", :uid => @facebook_uid).first
    if @user && @user.persisted? && @user.is_logged_in?
      sign_in @user, :event => :authentication
    end
    respond_to do |format|
      format.json {render json: {status: "OK"}}
    end
  end
end