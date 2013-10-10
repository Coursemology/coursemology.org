class UserAchievementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course
  load_and_authorize_resource :user_achievement

  before_filter :load_general_course_data

  def index

  end

  def destroy
    title = @user_achievement.achievement.title
    @user_achievement.destroy
    flash[:notice] = "Achievement #{title} has been successfully removed from #{@user_course.name}."
    redirect_to course_user_course_user_achievements_path

  end
end
