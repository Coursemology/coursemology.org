class LessonPlanEntriesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_entry, through: :course

  before_filter :load_general_course_data, :only => [:index, :new, :edit]

  def index
    @milestones = @course.lesson_plan_milestones.order("start_at")
    
    if @milestones.length > 0
      last_milestone = @milestones[@milestones.length - 1]
      first_milestone = @milestones[0]
    else
      first_milestone = nil
      last_milestone = nil
    end
    
    if last_milestone and last_milestone.end_at
      other_entries = entries_between_date_range(last_milestone.end_at.advance(:days =>1), nil)
    elsif last_milestone
      other_entries = []
    else
      other_entries = entries_between_date_range(nil, nil)
    end

    other_entries_milestone = LessonPlanMilestone.create_virtual("Other Items", other_entries)
    other_entries_milestone.previous_milestone = last_milestone
    @milestones <<= other_entries_milestone


    if first_milestone
      entries_before_first = entries_between_date_range(nil, first_milestone.start_at)
      if entries_before_first.length > 0
        previous_entries_milestone = LessonPlanMilestone.create_virtual("Prior Items", entries_before_first)
        @milestones.insert(0, previous_entries_milestone)
      end
    end
  end

  def new
    @start_at = params[:start_at]
    @end_at = params[:end_at]

    @start_at = DateTime.strptime(@start_at, '%d-%m-%Y') if @start_at
    @end_at = DateTime.strptime(@end_at, '%d-%m-%Y') if @end_at
  end

  def create
    @lesson_plan_entry.creator = current_user
    @lesson_plan_entry.resources = if params[:resources] then
                                     build_resources(params[:resources])
                                   else
                                     []
                                   end
    
    respond_to do |format|
      if @lesson_plan_entry.save then
        path = course_lesson_plan_path(@course) + "#entry-" + @lesson_plan_entry.id.to_s
        format.html { redirect_to path,
                      notice: "The lesson plan entry #{@lesson_plan_entry.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    @lesson_plan_entry.resources = if params[:resources] then
                                     build_resources(params[:resources])
                                   else
                                     []
                                   end
    
    respond_to do |format|
      if @lesson_plan_entry.update_attributes(params[:lesson_plan_entry]) && @lesson_plan_entry.save then
        path = course_lesson_plan_path(@course) + "#entry-" + @lesson_plan_entry.id.to_s
        format.html { redirect_to path,
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
    options[:template] = "/lesson_plan/#{options[:action] || params[:action]}"
    super(*(args << options))
  end

  # Builds the resource array to be assigned to a model from form parameters
  def build_resources(param)
    resources = []
    param.each { |r|
      obj_parts = r.split(',')
      res = LessonPlanResource.new
      res.obj_id = obj_parts[0]
      res.obj_type = obj_parts[1]
      resources.push(res)
    }

    resources
  end

  def entries_between_date_range(start_date, end_date)
    if can? :manage, Mission
      virtual_entries = @course.lesson_plan_virtual_entries(start_date, end_date)
    else
      virtual_entries = @course.lesson_plan_virtual_entries(start_date, end_date).select { |entry| entry.is_published }
    end

    after_start = if start_date then "AND start_at > :start_date " else "" end
    before_end = if end_date then "AND end_at < :end_date" else "" end

    actual_entries = @course.lesson_plan_entries.where("TRUE " + after_start + before_end,
      :start_date => start_date, :end_date => end_date)

    entries_in_range = virtual_entries + actual_entries
    entries_in_range.sort_by { |e| e.start_at }
  end
end
