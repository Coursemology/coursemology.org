class CourseGroupsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:instructors,:manage_students,:add_student]

  def manage_students
    @students_course = @course.user_courses.sort_by { |uc| uc.user.name }
  end

  def add_student
    respond_to do |format|
      format.json { render text: {} }
    end
  end
end
