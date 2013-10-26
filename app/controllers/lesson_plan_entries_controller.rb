class LessonPlanEntriesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :lesson_plan_entry, through: :course

  before_filter :load_general_course_data, :only => [:index]
  
  def index
    
  end

  def new
  end

  def create
    @lesson_plan_entry.creator = current_user

    respond_to do |format|
      if @lesson_plan_entry.save
        format.html { redirect_to course_lesson_plan_path(@course),
                      notice: "The lesson plan entry #{@lesson_plan_entry.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

private
  def render(*args)
    options = args.extract_options!
    options[:template] = "/lesson_plan/#{params[:action]}"
    super(*(args << options))
  end
end
