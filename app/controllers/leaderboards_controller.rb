class LeaderboardsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show]

  def show
    # 1 list for top 10 by EXP
    # 1 list for top 10 by achievements
    student_courses = @course.student_courses
    @top_10_exp = student_courses.order('exp DESC').first(10)
    @top_10_ach = student_courses.sort_by { |sc| sc.user_achievements.count }.reverse.first(10)
  end
end
