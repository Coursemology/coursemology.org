class Assessment::GradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, through: :course
  load_and_authorize_resource :submission, class: "Assessment::Submission", through: :assessment
  load_and_authorize_resource :grading, through: :submission, class: "Assessment::Grading"

  before_filter :load_general_course_data, only: [:new, :edit, :show]
  # note: it only handles view & grading of missions

  include GradingsSummaryBuilder

  def new
    if @submission.gradings.count > 0
      redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @submission.gradings.first)
      return
    end

    @summary = {qn_ans: {}}

    @assessment.questions.each_with_index do |q,i|
      @summary[:qn_ans][q.id] = { qn: q.specific, i: i + 1 }
    end

    @submission.build_initial_answers if @submission.assessment.questions.count != @submission.answers.count

    @submission.eval_answer

    @submission.answers.each do |ans|
      qn = ans.question
      @summary[:qn_ans][qn.id][:ans] = ans

      #suggest grading for auto grading question
      if qn.is_a?(Assessment::CodingQuestion) && qn.auto_graded?
        results = ans.result_hash["eval"]
        evals = results ? results.select { |r| r }.length : 0
        tests = qn.data_hash["eval"].length
        tests = tests == 0 ? 1 : tests
        grade = (qn.max_grade * evals / tests).to_i
        ag = ans.build_answer_grading
        ag.grade = grade
        @summary[:qn_ans][qn.question.id][:grade] = ag
      elsif qn.is_a?(Assessment::GeneralQuestion) && qn.auto_graded?
        # Check saved auto-grading options and suggest a grade
        case qn.auto_grading_type
        when :exact
          grade = auto_grading_exact_grade(qn, ans.content)
        when :keyword
          grade = auto_grading_keyword_grade(qn, ans.content)
        else
          grade = 0
        end
        ag = ans.build_answer_grading
        ag.grade = grade
        @summary[:qn_ans][qn.question.id][:grade] = ag
      end
    end
  end

  #TODO,refactoring, duplicate code with update
  def create
    if @submission.graded?
      flash[:error] = "Submission has already been graded by " + @submission.gradings.last.grader.name
      redirect_to course_assessment_submission_grading_path(@course, @assessment, @submission,  @submission.gradings.last)
      return
    end

    invalid_assign = false
    @grading.grade = 0

    params[:ags].each do |ag|
      @ag = @grading.answer_gradings.build(ag)
      @ag.grader = current_user
      @ag.grader_course = curr_user_course
      unless validate_gradings(@ag, ag)
        invalid_assign = true
        break
      end

      @grading.grade += @ag.grade
    end

    if @grading.grade > @assessment.max_grade || @grading.exp > @assessment.exp
      invalid_assign = true
    end

    @grading.grader = current_user
    @grading.grader_course = curr_user_course
    @grading.student = @submission.std_course

    if invalid_assign
      grade_error_response
    elsif @grading.save
      @submission.set_graded

      respond_to do |format|
        format.html { redirect_to course_assessment_submission_path(@course, @assessment, @submission),
                                  notice: "Grading has been recorded." }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end
  end

  def update
    invalid_assign = false
    @grading.grade = 0
    @grading.exp = params[:assessment_grading][:exp].to_i

    params[:ags].each do |v|
      if v.is_a? Array
        @ag = @grading.answer_gradings.find(v.first)
        ag = v.last
      else
        @ag = @grading.answer_gradings.build(v)
        @ag.grader = current_user
        @ag.grader_course = curr_user_course
        ag = v
      end
      unless validate_gradings(@ag, ag)
        invalid_assign = true
        break
      end
      if @ag.grade != ag[:grade].to_f
        @ag.grade = ag[:grade].to_f
        @ag.grader = current_user
        @ag.grader_course = curr_user_course
        #is this save necessary
        @ag.save
      end

      @grading.grade += @ag.grade
    end

    @submission.set_graded
    if @grading.grade > @assessment.max_grade || @grading.exp > @assessment.exp
      invalid_assign = true
    end
    unless @grading.grader_course_id
      @grading.grader_course_id = curr_user_course.id
    end
    if invalid_assign
      grade_error_response(true)
    elsif @grading.save
      respond_to do |format|
        format.html { redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @grading),
                                  notice: "Grading has been recorded." }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end

  end

  def edit
    build_gradings_summary
  end

  def show
    if curr_user_course.is_staff?
      redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @grading)
      return
    end
    build_gradings_summary true
    @pdf_export = @course.pdf_export_enabled?('mission')
    respond_to do |format|
      format.html
      if @pdf_export
        format.pdf do
          load_settings_for_printing
          render :pdf => "Mission - #{@assessment.title}",
            :disposition => (params[:commit] == 'Save as PDF') ? 'attachment' : 'inline'
        end
      end
    end
  end


  rescue_from CanCan::AccessDenied do |exception|
    unless current_user
      redirect_to new_user_session_path
      return
    end
    @submission ||= not_found
    if @submission.std_course == curr_user_course
      redirect_to course_assessment_submission_path(@course, @assessment, @submission)
    else
      flash[:error] = "You are not authorized to access the page :("
      redirect_to @course
    end
  end

  private

  # Compare answers against attempts, modulo case and punctuation
  def auto_grading_equal(answer, attempt)
    answer = answer.gsub(/[^\w\d\s]/, '')
    attempt = attempt.gsub(/[^\w\d\s]/, '')
    attempt.casecmp(answer).zero?
  end

  # Given a question (and its exact auto-grading options) and an answer,
  # compares the given solution against the answers and computes a
  # suggested grade.
  def auto_grading_exact_grade(question, answer)
    correct = question.auto_grading_exact_options.
              select(&:correct?).map(&:answer)
    correct.each do |c|
      if auto_grading_equal(answer, c)
        return question.max_grade
      end
    end

    wrong = question.auto_grading_exact_options.
            reject(&:correct?).map(&:answer)
    wrong.each do |c|
      if auto_grading_equal(answer, c)
        return 0
      end
    end

    # Suggest 0 by default
    0
  end

  # Given a question (and its keyowrd auto-grading options) and an answer,
  # chceks the given solution for the presence of the keywords and computes
  # a suggested grade.
  def auto_grading_keyword_grade(question, answer)
    score = question.auto_grading_keyword_options.map do |option|
      if answer.match(keyword_regex(option.keyword))
        option.score
      else
        0
      end
    end.reduce(:+)
    [score, question.max_grade].min
  end

  # Given a keyword, returns a sanitised regex which matches it. Keywords are assumed
  # to be single alphanumeric words.
  # This is used in auto-grading and ensures that the same matching strategy is used
  # everywhere keyword matches are required.
  def keyword_regex(keyword)
    keyword = keyword.gsub(/[^\d\w]/, '')
    Regexp.new("\\b#{keyword}\\b")
  end
  helper_method :keyword_regex

  def validate_gradings(ag_record, ag)
    grade = ag[:grade].strip
    max_grade = @assessment.max_grade
    unless ag[:exp]
      return validate_grade(grade, max_grade)
    end

    max_exp = @assessment.exp
    qn_grade = ag_record.student_answer.qn.max_grade
    qn_exp = max_exp * (qn_grade.to_f / max_grade.to_f)
    exp = ag[:exp].strip
    if !validate_grade(grade, qn_grade) || !validate_grade(exp, qn_exp.to_i)
      return false
    end
    true
  end

  def validate_grade(grade, max_grade)
    if grade.match(/^[\-|\+|\d|\.]\d*(\.*)\d*$/) and (grade.to_f <= max_grade)
      return true
    end
    false
  end

  def grade_error_response(edit = false)
    respond_to do |format|
      flash[:error] = "Grading appears to have failed. Did you, for example, try to give grade/exp > max? ;)"
      if edit
        format.html { redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @grading)}
      else
        format.html { redirect_to new_course_assessment_submission_grading_path(@course, @assessment, @submission)}
      end
    end
  end

end
