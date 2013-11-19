class LessonPlanMilestonesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_milestone, through: :course, except: [:bulk_update]

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
    @milestones = @course.lesson_plan_milestones.order("end_at")
    render "/lesson_plan/overview"
  end

  def bulk_update
    authorize! :manage, :bulk_update
    milestones = params[:milestones]
    entries = params[:lesson_plan_entry]

    LessonPlanEntry.transaction do
      milestones.each do |key, val|
        milestone = @course.lesson_plan_milestones.where(id: key).first
        milestone.update_attributes!(val)
        unless milestone.changed?
          next
        end

        milestone.save!
      end

      entries.each do |key, val|
        entry = @course.lesson_plan_entries.where(id: key).first
        entry.update_attributes!(val)
        unless entry.changed?
          next
        end

        entry.save!
      end
    end

    redirect_to course_lesson_plan_path(@course), notice: 'The Lesson Plan was updated successfully.'
  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/milestone_#{options[:action] || params[:action]}"
    super(*(args << options))
  end
end
