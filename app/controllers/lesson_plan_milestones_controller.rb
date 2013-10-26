class LessonPlanMilestonesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_milestone, through: :course

  before_filter :load_general_course_data, :only => [:index]

  def show

  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/milestone_#{params[:action]}"
    super(*(args << options))
  end
end
