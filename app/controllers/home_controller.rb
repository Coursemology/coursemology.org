class HomeController < ApplicationController

  def index
    puts @user.to_json
    @user_courses = current_user.user_courses
    puts @user_courses.to_json
    @courses = current_user.courses
    puts @courses.to_json
  end

end
