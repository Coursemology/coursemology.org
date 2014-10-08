class SurveysController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course

  before_filter :load_general_course_data, only: [:index, :new, :show, :edit, :stats, :summary]

  require 'axlsx'

  def index
    @surveys = @course.surveys.accessible_by(current_ability)
    #TODO
    @time_format =  @course.time_format('mission')

    if can? :manage, Survey
      @stats = {}
      total = @course.user_courses.real_students.count
      @surveys.each do |survey|
        sub = survey.submissions.select {|s| s.user_course and s.user_course.is_student? and !s.user_course.is_phantom? }.count
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
    @survey.sections << @survey_section if @survey.is_contest? && @survey.sections.empty?
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
    @submissions = @survey.submissions.all
    @staff_courses = @course.user_courses.staff.order(:name)
    @std_courses = @course.user_courses.student.order(:name).where(is_phantom: false)
    @std_courses_phantom = @course.user_courses.student.order(:name).where(is_phantom: true)
  end

  def summary
    @tab = params[:_tab]
    include_phantom = @tab == "summary_phantom"
    @summaries = []
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
  end

  def summary_with_format
    respond_to do |format|
      format.csv { send_data summary_csv(params[:_tab] == "summary_phantom"), type: "text/csv", :disposition => "attachment; filename=#{@survey.title}.csv" }
      if params[:format] == 'xlsx'
        filename = summary_xlsx(params[:_tab] == "summary_phantom")
        format.xlsx {send_file filename, :disposition => "attachment; filename=#{@survey.title}.xlsx"}
      end
    end
  end

  def summary_xlsx(include_phantom = true)
    export_dir = "#{Rails.root}/tmp/export/#{curr_user_course.id}"
    Dir.exist?(export_dir) ||  FileUtils.mkdir_p(export_dir)

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Summary") do |sheet|
        summary_rows(include_phantom).each do |row|
          sheet.add_row row
        end
      end
      p.serialize  "#{export_dir}/#{@survey.title}.xlsx"
    end
    "#{export_dir}/#{@survey.title}.xlsx"
  end

  def summary_csv(include_phantom = true)
    CSV.generate({}) do |csv|
      summary_rows(include_phantom).each do |row|
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
      if params[:order] == 'yes' || @survey.is_contest?
        summary[:options] = question.options.order("count desc")
      else
        summary[:options] = question.options
      end
      if @survey.is_contest?
        summary[:options] = summary[:options].limit(10)
      end
    end
    summary
  end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html {redirect_to course_surveys_path}
    end
  end

  private

  def summary_rows(include_phantom = true)
    questions = @survey.questions

    rows = []
    if @survey.anonymous?
      rows << questions.map { |qn| qn.description }
    else
      rows << ["Name"] + questions.map { |qn| qn.description }
    end
    (include_phantom ? @survey.submissions.students : @survey.submissions.students.exclude_phantom).order(:submitted_at).each do |submission|
      row = []
      row << (submission.user_course.nil? ? "" :  submission.user_course.name) unless @survey.anonymous?
      questions.each do |qn|
        ans = submission.get_answer(qn)
        ans = qn.is_essay? ? ans.map {|a| a.text }.join(",") : ans.map {|q| q.option.description }.join(",")
        row << ans
      end
      rows << row
    end
    rows
  end
end
