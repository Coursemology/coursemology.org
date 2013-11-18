class LessonPlanMilestonesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_milestone, through: :course

  before_filter :load_general_course_data, :except => [:destroy]

  def show

  end

  def new

  end

  def create
    @lesson_plan_milestone.creator = current_user
    @lesson_plan_milestone.end_at = @lesson_plan_milestone.end_at.end_of_day if @lesson_plan_milestone.end_at

    respond_to do |format|
      if @lesson_plan_milestone.save then
        path = course_lesson_plan_path(@course) + '#milestone-' + @lesson_plan_milestone.id.to_s
        format.html { redirect_to path,
                      notice: "The lesson plan milestone #{@lesson_plan_milestone.title} has been created." }
        format.json { render json: {status: 'OK'} }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit

  end

  def update
    @lesson_plan_milestone.update_attributes(params[:lesson_plan_milestone])
    @lesson_plan_milestone.end_at = @lesson_plan_milestone.end_at.end_of_day

    respond_to do |format|
      if @lesson_plan_milestone.save then
        path = course_lesson_plan_path(@course) + '#milestone-' + @lesson_plan_milestone.id.to_s
        format.html { redirect_to path,
                      notice: "The lesson plan milestone #{@lesson_plan_milestone.title} has been updated." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def destroy
    @lesson_plan_milestone.destroy
    respond_to do |format|
      format.html { redirect_to course_lesson_plan_path(@course),
                    notice: "The lesson plan milestone #{@lesson_plan_milestone.title} has been removed." }
    end
  end
    
  def overview
    render "/lesson_plan/overview"
  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/milestone_#{options[:action] || params[:action]}"
    super(*(args << options))
  end
end
