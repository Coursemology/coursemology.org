class SurveysController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course

  before_filter :load_general_course_data, only: [:index, :new, :show, :edit, :stats, :summary]
  def index
    @surveys = @course.surveys.accessible_by(current_ability)
    @time_format =  @course.mission_time_format

    if can? :manage, Survey
      @stats = {}
      total = @course.user_courses.real_students.count
      @surveys.each do |survey|
        sub = survey.survey_submissions.select {|s| s.user_course and s.user_course.is_student? and !s.user_course.is_phantom? }.count
        @stats[survey] = {started: sub, total: total}
      end
    end
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
    @survey_section = SurveySection.new
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
    @summaries = []
    @survey.questions.each do |question|
      rows = {}
      summary = {}
      summary[:question] = question
      summary[:total] = question.no_unique_voters


      #TODO: hardcoded 10
      summary[:options] = question.options.order("count desc").first(10)
      @summaries << summary
    end
  end

  #def summary
  #  @charts = []
  #  @survey.questions.each do |question|
  #    rows = {}
  #    data_table = GoogleVisualr::DataTable.new
  #    data_table.new_column('string', 'Rank' )
  #    data_table.new_column('number', 'No. of votes')
  #    #data_table.new_column('string', nil, nil, 'tooltip')
  #    question.survey_mrq_answers.each do |answer|
  #      answer.options.each do |option|
  #        if rows[option]
  #          rows[option] += 1
  #        else
  #          rows[option] = 1
  #        end
  #      end
  #    end
  #  rows.sort_by{|k, v| v}.reverse[0, 10].each do |key, value|
  #      data_table.add_row([key.description, value])
  #    end
  #    opt = { width: 600, height: 600, title: question.description }
  #    @charts << GoogleVisualr::Interactive::BarChart.new(data_table, opt)
  #  end
  #  #@charts = @charts[0,1]
  #end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to course_surveys_path}
    end
  end

end
