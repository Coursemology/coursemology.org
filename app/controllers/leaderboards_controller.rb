class LeaderboardsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show]

  def show
    # 1 list for top 10 by EXP
    # 1 list for top 10 by achievements
    top_pref = @course.leaderboard_no_pef.prefer_value.to_i
    student_courses = @course.student_courses
    @top_10_exp = student_courses.student.where(is_phantom: false).order('exp DESC').first(top_pref)
    @top_10_ach = student_courses.student.where(is_phantom: false).sort_by { |sc| sc.user_achievements.count }.reverse.first(top_pref)
  end
end
