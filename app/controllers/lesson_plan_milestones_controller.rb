class LessonPlanMilestonesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_milestone, through: :course, except: [:create, :bulk_update]

  before_filter :load_general_course_data, :except => [:destroy]

  def show

  end

  def new

  end

  def create
    authorize! :create, LessonPlanMilestone
    raw_milestones = not(params[:lesson_plan_milestone]['0']) ?
      {'0' => params[:lesson_plan_milestone]} :
      params[:lesson_plan_milestone]
    milestones = []
    raw_milestones.each_pair do |key, value|
      milestone = LessonPlanMilestone.create
      milestone.course = @course
      milestone.attributes = value
      milestone.creator = current_user
      milestone.start_at = milestone.start_at.beginning_of_day if milestone.start_at
      milestone.end_at = milestone.end_at.end_of_day if milestone.end_at
      milestones.push(milestone)
    end

    respond_to do |format|
      begin
        LessonPlanMilestone.transaction do
          milestones.each {|milestone|
            milestone.save!
          }
        end
      rescue Exception => e
        @lesson_plan_milestone = milestones[0]
        format.html { render action: "new" }
        format.json { render json: { message: e.message, status: 400 }}
      else
        path = course_lesson_plan_path(@course, :anchor => 'milestone-' + milestones[0].id.to_s)
        format.html {
          notice = milestones.length > 1 ?
            "#{milestones.length} new milestones were created." :
            "The lesson plan milestone #{milestones[0].title} has been created."
          redirect_to path, notice: notice
        }
        format.json { render json: {status: 'OK'} }
      end
    end
  end

  def edit

  end

  def update
    @lesson_plan_milestone.update_attributes(params[:lesson_plan_milestone])
    @lesson_plan_milestone.start_at = @lesson_plan_milestone.start_at.beginning_of_day
    if @lesson_plan_milestone.end_at then
      @lesson_plan_milestone.end_at = @lesson_plan_milestone.end_at.end_of_day
    end

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
      format.html { redirect_to :back,
                    notice: "The lesson plan milestone #{@lesson_plan_milestone.title} has been removed." }
    end
  end

  def bulk_update
    authorize! :manage, LessonPlanMilestone
    authorize! :manage, LessonPlanEntry
    milestones = params[:milestones]
    entries = params[:lesson_plan_entry] || []

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
