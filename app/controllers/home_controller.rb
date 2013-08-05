class HomeController < ApplicationController

  def index
    @courses = current_user.courses

    if @courses.count == 1
      user_course = UserCourse.find_by_user_id_and_course_id(current_user, @courses.first)
      if user_course.is_student? &&  (cannot? :manage, Course)
        redirect_to course_path(@courses.first)
      end
    end

    @courses_std = current_user.user_courses.student.map { |uc| uc.course }
    @courses_staff = current_user.user_courses.staff.map { |uc| uc.course }
    @courses_shared = current_user.user_courses.shared.map { |uc| uc.course }
    if @courses.count == 0
      @all_courses = Course.all
    end
  end
end
