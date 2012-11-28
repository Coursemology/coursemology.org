class HomeController < ApplicationController

  def index
    @user_courses = current_user.user_courses
    @courses = current_user.courses
    puts @courses.to_json
  end

end
