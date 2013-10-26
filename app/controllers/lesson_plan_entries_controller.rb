class LessonPlanEntriesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_entry, through: :course

  before_filter :load_general_course_data, :only => [:index]
  
  def index
    @milestones = @course.lesson_plan_milestones.all

    # Add the entries which don't belong in any milestone
    other_entries = if @milestones.length > 0 then
        from = @milestones[@milestones.length - 1].end_at
        @course.lesson_plan_entries.where("end_at > :end_at",
          :end_at => from) +
        @course.lesson_plan_virtual_entries(from)
      else
        @course.lesson_plan_entries.all +
        @course.lesson_plan_virtual_entries
      end

    other_entries_milestone = LessonPlanMilestone.create_virtual(other_entries)
    @milestones <<= other_entries_milestone
  end

  def new
  end

  def create
    @lesson_plan_entry.creator = current_user

    respond_to do |format|
      if @lesson_plan_entry.save then
        format.html { redirect_to course_lesson_plan_path(@course),
                      notice: "The lesson plan entry #{@lesson_plan_entry.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @lesson_plan_entry.update_attributes(params[:lesson_plan_entry]) && @lesson_plan_entry.save then
        format.html { redirect_to course_lesson_plan_path(@course),
                      notice: "The lesson plan entry #{@lesson_plan_entry.title} has been updated." }
      else
        format.html { render action: "index" }
      end
    end
  end

  def destroy
    @lesson_plan_entry.destroy
    respond_to do |format|
      format.html { redirect_to course_lesson_plan_path(@course),
                    notice: "The lesson plan entry #{@lesson_plan_entry.title} has been removed." }
    end
  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/#{params[:action]}"
    super(*(args << options))
  end
end
