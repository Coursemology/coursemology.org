class DuplicateController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:manage]

  def manage
    @missions = @course.missions
    @trainings = @course.trainings
  end

  def duplicate_course

    require 'duplication'

    authorize! :duplicate, @course
    clone = Duplication.duplicate_course(current_user, @course)
    respond_to do |format|
      format.html { redirect_to edit_course_path(clone),
                    notice: "The course '#{@course.title}' has been duplicated." }
    end
  end
end
