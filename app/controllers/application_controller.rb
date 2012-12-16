class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    puts 'Access denied! Current user: ', current_user
    redirect_to access_denied_path, alert: exception.message
  end
end
