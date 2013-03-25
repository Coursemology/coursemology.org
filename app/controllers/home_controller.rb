class HomeController < ApplicationController

  def index
    @courses = current_user.courses
    @courses_std = current_user.user_courses.student.map { |uc| uc.course }
    @courses_lect = current_user.user_courses.lecturer.map { |uc| uc.course }
    @courses_shared = current_user.user_courses.shared.map { |uc| uc.course }
    if @courses.count == 0
      @all_courses = Course.all
    end
  end
end
