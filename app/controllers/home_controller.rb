class HomeController < ApplicationController

  def index
    @user_courses = current_user.user_courses
    @courses = current_user.courses
    if @courses.count == 0
      @all_courses = Course.all
    end
  end
end
