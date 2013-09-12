class SurveysController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course

  before_filter :load_general_course_data, only: [:index, :new, :show, :edit, :stats, :summary]
  def index
    @surveys = @course.surveys
    @time_format =  @course.mission_time_format
  end

  def new
    @survey.open_at =  DateTime.now.beginning_of_day + 1.day
    @survey.expire_at = DateTime.now.beginning_of_day + 8.days
    @survey.creator = current_user
  end

  def create
    respond_to do |format|
      if @survey.save
        format.html { redirect_to course_survey_path(@course, @survey),
                                  notice: "The survey '#{@survey.title}' has been created." }
      end
      format.html { render action: "new" }
    end
  end

  def show

  end

  def edit

  end

  def update
    respond_to do |format|
      if @survey.update_attributes(params[:survey])
        format.html { redirect_to course_survey_path(@course, @survey),
                                  notice: "The survey '#{@survey.title}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end

  end

  def stats
    @submissions = @survey.survey_submissions.all
    @staff_courses = @course.user_courses.staff.order(:name)
    @std_courses = @course.user_courses.student.order(:name).where(is_phantom: false)
    @std_courses_phantom = @course.user_courses.student.order(:name).where(is_phantom: true)
  end

  def summary

  end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to course_surveys_path}
    end
  end
end
