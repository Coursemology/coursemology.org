class LeaderboardsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, only: [:show]

  def show

    top_pref = @course.leaderboard_no_pef.prefer_value.to_i
    student_courses = @course.student_courses
    @top_exp = student_courses.student.where(is_phantom: false)
        .order('level_id DESC, exp DESC, exp_updated_at ASC, id ASC')
        .first(top_pref)
    @top_ach = student_courses.student.where(is_phantom: false)
        .order('exp_updated_at ASC, id ASC')
        .sort_by { |sc| sc.user_achievements.count }.reverse.first(top_pref)
  end
end
