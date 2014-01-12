class HomeController < ApplicationController

  def index
    @courses = current_user.courses

    redirect_course = @courses.count == 1 ? @courses.first :
        current_user.user_courses.order("last_active_time desc").first.course

    redirect_to course_path(redirect_course)
  end

  def my_courses
    @courses = current_user.courses

    @courses_std = current_user.user_courses.student.map { |uc| uc.course }
    @courses_staff = current_user.user_courses.staff.map { |uc| uc.course }
    @courses_shared = current_user.user_courses.shared.map { |uc| uc.course }
    if @courses.count == 0
      @all_courses = Course.where(is_publish: true)
    end
  end
end
