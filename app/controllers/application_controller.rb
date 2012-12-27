class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    puts 'Access denied! Current user: ', current_user
    redirect_to access_denied_path, alert: exception.message
  end

  def current_uc
    if current_user and @course
      @current_uc ||= UserCourse.find_by_user_id_and_course_id(
        current_user.id,
        @course.id
      )
    end
    return @current_uc
  end

  helper_method :current_uc
end
