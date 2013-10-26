class LessonPlanMilestonesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_milestone, through: :course

  before_filter :load_general_course_data, :only => [:index]

  def show

  end

  def new

  end

  def create
    @lesson_plan_milestone.creator = current_user

    respond_to do |format|
      if @lesson_plan_milestone.save then
        format.html { redirect_to course_lesson_plan_milestone_path(@course, @lesson_plan_milestone),
                      notice: "The lesson plan milestone #{@lesson_plan_milestone.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/milestone_#{params[:action]}"
    super(*(args << options))
  end
end
