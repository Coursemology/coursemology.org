class HomeController < ApplicationController

  def index
    @courses = current_user.courses

    redirect_course = @courses.count == 1 ? @courses.first :
        current_user.user_courses.order("last_active_time desc").first.course

    redirect_to course_path(redirect_course)
  end
end
