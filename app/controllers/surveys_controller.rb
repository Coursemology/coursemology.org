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
    @tab = "stats"
    @submissions = @survey.survey_submissions.all
    @staff_courses = @course.user_courses.staff.order(:name)
    @std_courses = @course.user_courses.student.order(:name).where(is_phantom: false)
    @std_courses_phantom = @course.user_courses.student.order(:name).where(is_phantom: true)
  end

  def summary
    @tab = params[:_tab]
    include_phantom = @tab == "summary_phantom"
    @summaries = []
    if @survey.has_section?
      @survey.sections.each do |section|
        summary = {}
        summary[:section] = section
        summary_qns = []
        section.questions.each do |question|
          summary_qns << question_summary(question, include_phantom)
        end
        summary[:questions] = summary_qns
        @summaries << summary
      end
    else
      @survey.questions.each do |question|
        @summaries << question_summary(question)
      end
    end
  end

  def summary_with_format
    respond_to do |format|
      format.csv { send_data summary_csv(params[:_tab] == "summary_phantom"), :disposition => "attachment; filename=#{@survey.title}.csv" }
    end
  end

  def summary_csv(include_phantom = true)
    CSV.generate({}) do |csv|
      questions = @survey.questions
      csv << ["Name"] + questions.map {|qn| qn.description }
      (include_phantom ? @survey.submissions : @survey.submissions.exclude_phantom).order(:submitted_at).each do |submission|
        row = []
        row << (submission.user_course.nil? ? "" :  submission.user_course.name)
        questions.each do |qn|
          ans = submission.get_answer(qn)
          ans = qn.is_essay? ? ans.map {|a| a.text }.join(",") : ans.map {|q| q.option.description }.join(",")
          row << ans
        end
        csv << row
      end
    end
  end

  def question_summary(question, include_phantom = true)
    summary = {}
    summary[:question] = question

    if question.type == SurveyQuestionType.Essay.first
      summary[:responds] = question.essay_answers(include_phantom)
    else
      summary[:total] = question.no_unique_voters(include_phantom)
      #TODO: hardcoded 10
      summary[:options] = question.options.order("count desc")
      unless @survey.has_section?
        summary[:options] = summary[:options].first(10)
      end
    end
    summary
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
