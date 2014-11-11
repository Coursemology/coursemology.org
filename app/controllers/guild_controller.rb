class GuildController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :guild, through: :course
  before_filter :load_general_course_data, only: [:index, :view, :manage] #for pages that client sees

  def index
  end

  def view
  end

  def manage
    @student_courses = @course.user_courses.student.where(is_phantom: false).order('lower(name)')
  end

end
