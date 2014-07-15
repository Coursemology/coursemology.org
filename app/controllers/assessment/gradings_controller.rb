class Assessment::GradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, through: :course
  load_and_authorize_resource :submission, class: "Assessment::Submission", through: :assessment
  load_and_authorize_resource :grading, through: :submission, class: "Assessment::Grading"

  before_filter :load_general_course_data, only: [:new, :edit]

  # note: it only handles view & grading of missions

  def new
    if @submission.gradings.count > 0
      redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @submission.gradings.first)
      return
    end

    @summary = {qn_ans: {}}

    @assessment.questions.each_with_index do |q,i|
      @summary[:qn_ans][q.id] = { qn: q.specific, i: i + 1 }
    end

    eval_answer

    @submission.answers.each do |ans|
      qn = ans.question.specific
      @summary[:qn_ans][qn.question.id][:ans] = ans

      #suggest grading for auto grading question
      if qn.class == Assessment::CodingQuestion && qn.auto_graded?
        results = ans.result_hash["eval"]
        evals = results ? results.select {|r| r}.length : 0
        tests = qn.data_hash["eval"].length
        tests = tests == 0 ? 1 : tests
        grade = (qn.max_grade * evals / tests).to_i
        ag = Assessment::AnswerGrading.new
        ag.grade = grade
        @summary[:qn_ans][qn.question.id][:grade] = ag
      end
    end
  end

  def create
    if @submission.graded?
      flash[:error] = "Submission has already been graded by " + @submission.gradings.last.grader.name
      redirect_to course_mission_submission_path(@course, @assessment, @submission)
      return
    end


    invalid_assign = false
    @grading.grade = 0

    params[:ags].each do |ag|
      @ag = @grading.answer_gradings.build(ag)
      unless validate_gradings(@ag, ag)
        invalid_assign = true
        break
      end

      @ag.grader = curr_user_course
      @grading.grade += @ag.grade
    end

    if @grading.grade > @assessment.max_grade || @grading.exp > @assessment.exp
      invalid_assign = true
    end

    @grading.grader = curr_user_course
    g_log = @grading.grading_logs.build
    g_log.grader = curr_user_course
    g_log.grade = @grading.grade
    g_log.exp = @grading.exp

    if invalid_assign
      grade_error_response
    elsif @grading.save
      @submission.set_graded

      if @course.email_notify_enabled? PreferableItem.new_grading and @assessment.published?
        UserMailer.delay.new_grading(
            @submission.std_course.user,
            course_assessment_submission_url(@course, @assessment, @submission)
        )
      end
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

  def edit
    @summary = {qn_ans: {}}

    if @grading.autograding_refresh
      eval_answer
      @grading.update_attribute :autograding_refresh, false
    end

    @assessment.questions.each_with_index do |q,i|
      @summary[:qn_ans][q.id] = { qn: q.specific, i: i + 1 }
    end

    @submission.answers.each do |sa|
      qn = sa.qn
      @summary[:qn_ans][qn.id][:ans] = sa
      # @qadata[:aws][sa.id] = sa
    end

    #TODO, potential read row by row
    @grading.answer_gradings.each do |ag|
      qn = ag.answer.question
      @summary[:qn_ans][qn.id][:grade] = ag
    end
  end

  def update
    @grading.grade = 0
    @grading.exp = 0
    invalid_assign = false
    if @assessment.single_question?
      @grading.grade = params[:grade_sum].to_i
    else
      params[:ags].each do |agid, ag|
        @ag = AnswerGrading.find(agid)
        unless validate_gradings(@ag, ag)
          invalid_assign = true
          break
        end
        @ag.update_attributes(ag)
        #@ag.grader = current_user
        @grading.grade += ag[:grade].to_i
        #@grading.exp += ag[:exp].to_i
      end
    end
    @grading.last_grade_updated = Time.now
    @submission.set_graded
    @grading.exp = params[:exp_sum].to_i
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
        format.html { redirect_to course_mission_submission_path(@course, @assessment, @submission),
                                  notice: "Grading has been recorded." }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
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
      redirect_to course_mission_submission_path(@course, @assessment, @submission)
    else
      flash[:error] = "You are not authorized to access the page :("
      redirect_to @course
    end
  end

  private

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
    if grade.match(/^[\-|\+|\d]\d*$/) and (grade.to_i <= max_grade)
      return true
    end
    false
  end

  def grade_error_response(edit = false)
    respond_to do |format|
      flash[:error] = "Grading appears to have failed. Did you, for example, try to give grade/exp > max? ;)"
      if edit
        format.html { redirect_to edit_course_mission_submission_submission_grading_path(@course, @assessment, @submission)}
      else
        format.html { redirect_to new_course_mission_submission_submission_grading_path(@course, @assessment, @submission)}
      end
    end
  end

  def eval_answer
    # Thread.start {
    @submission.answers.coding.each do |ans|
      qn = ans.qn.specific
      unless qn.auto_graded?
        next
      end
      combined_code = PythonEvaluator.combine_code(ans.answer, qn.test_code)
      result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@assessment), combined_code, qn, true)
      ans.result = result.to_json
      ans.save
    end
    # }
  end
end
