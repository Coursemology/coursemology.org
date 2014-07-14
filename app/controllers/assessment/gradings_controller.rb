class Assessment::GradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, through: :course
  load_and_authorize_resource :submission, class: "Assessment::Submission", through: :assessment
  load_and_authorize_resource
  # load_and_authorize_resource :grading, through: :submission, class: "Assessment::Grading"

  before_filter :load_general_course_data, only: [:new, :edit]

  # note: it only handles view & grading of missions

  def new

    if @submission.gradings.count > 0
      redirect_to edit_course_mission_submission_submission_grading_path(@course, @mission,@submission, @submission.submission_gradings.first)
      return
    end

    @qadata = {}

    @assessment.questions.each_with_index do |q,i|
      @qadata[q.id] = { q: q, i: i + 1 }
    end

    eval_answer
    @submission.answers.each do |sa|
      qn = sa.qn
      @qadata[qn.id][:a] = sa
      #suggest grading for auto grading question

      if qn.specific.class == Assessment::CodingQuestion and qn.specific.auto_graded?
        results = sa.result_hash["evalTests"]
        evals = results ? results.select {|r| r}.length : 0
        tests = qn.data_hash["evalTests"].length
        tests = tests == 0 ? 1 : tests
        grade = (qn.max_grade * evals / tests).to_i
        ag = Assessment::AnswerGrading.new
        ag.grade = grade
        @qadata[qn.id][:g] = ag
      end
    end

    @do_grading = true
  end

  def create
    if @submission.graded?
      flash[:error] = "Submission has already been graded by " + @submission.final_grading.grader.name
      redirect_to course_mission_submission_path(@course, @mission, @submission)
      return
    end
    @submission_grading.total_grade = 0
    @submission_grading.total_exp = 0
    invalid_assign = false

    if @mission.single_question?
      @submission_grading.total_grade = params[:grade_sum].to_i
    else
      params[:ags].each do |ag|
        @ag = @submission_grading.answer_gradings.build(ag)
        unless validate_gradings(@ag, ag)
          invalid_assign = true
          break
        end

        @ag.grader = current_user
        @submission_grading.total_grade += @ag.grade
        #@submission_grading.total_exp += @ag.exp
      end
    end
    @submission_grading.total_exp = params[:exp_sum].to_i
    @submission_grading.grader = current_user
    @submission_grading.grader_course_id = curr_user_course.id
    if @submission_grading.total_grade > @mission.max_grade || @submission_grading.total_exp > @mission.exp
      invalid_assign = true
    end
    if invalid_assign
      grade_error_response
    elsif @submission_grading.save
      @submission.set_graded
      @submission.final_grading = @submission_grading
      @submission_grading.update_exp_transaction
      @submission.save

      if @course.email_notify_enabled? PreferableItem.new_grading and @mission.published?
        UserMailer.delay.new_grading(
            @submission.std_course.user,
            course_mission_submission_url(@course, @mission, @submission)
        )
      end
      respond_to do |format|
        format.html { redirect_to course_mission_submission_path(@course, @mission, @submission),
                                  notice: "Grading has been recorded." }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end
  end

  def edit
    @qadata = {}
    if @submission_grading.autograding_refresh
      eval_answer
      @submission_grading.update_attribute :autograding_refresh, false
    end
    @mission.get_all_questions.each_with_index do |q,i|
      @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
    end

    @submission.get_all_answers.each do |sa|
      qn = sa.qn
      @qadata[qn.id.to_s + qn.class.to_s][:a] = sa
    end

    @submission_grading.answer_gradings.each do |ag|
      qn = ag.student_answer.qn
      @qadata[qn.id.to_s + qn.class.to_s][:g] = ag
    end
  end

  def update
    @submission_grading.total_grade = 0
    @submission_grading.total_exp = 0
    invalid_assign = false
    if @mission.single_question?
      @submission_grading.total_grade = params[:grade_sum].to_i
    else
      params[:ags].each do |agid, ag|
        @ag = AnswerGrading.find(agid)
        unless validate_gradings(@ag, ag)
          invalid_assign = true
          break
        end
        @ag.update_attributes(ag)
        #@ag.grader = current_user
        @submission_grading.total_grade += ag[:grade].to_i
        #@submission_grading.total_exp += ag[:exp].to_i
      end
    end
    @submission_grading.last_grade_updated = Time.now
    @submission.set_graded
    #@submission_grading.grader = current_user
    @submission_grading.total_exp = params[:exp_sum].to_i
    if @submission_grading.total_grade > @mission.max_grade || @submission_grading.total_exp > @mission.exp
      invalid_assign = true
    end
    unless @submission_grading.grader_course_id
      @submission_grading.grader_course_id = curr_user_course.id
    end
    if invalid_assign
      grade_error_response(true)
    elsif @submission_grading.save
      @submission_grading.update_exp_transaction
      respond_to do |format|
        format.html { redirect_to course_mission_submission_path(@course, @mission, @submission),
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
      redirect_to course_mission_submission_path(@course, @mission, @submission)
    else
      flash[:error] = "You are not authorized to access the page :("
      redirect_to @course
    end
  end

  private

  def validate_gradings(ag_record, ag)
    grade = ag[:grade].strip
    max_grade = @mission.max_grade
    unless ag[:exp]
      return validate_grade(grade, max_grade)
    end

    max_exp = @mission.exp
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
        format.html { redirect_to edit_course_mission_submission_submission_grading_path(@course, @mission, @submission)}
      else
        format.html { redirect_to new_course_mission_submission_submission_grading_path(@course, @mission, @submission)}
      end
    end
  end

  def eval_answer
    # Thread.start {
    puts "Eval Coding Answer"
    @submission.answers.coding.each do |answer|
      qn = answer.qn.specific
      unless qn.auto_graded?
        next
      end
      combined_code = PythonEvaluator.combine_code(answer.code, qn.test_code)
      result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@mission), combined_code, qn.data_hash, true)
      answer.result = result.to_json
      puts result
      answer.save
    end
    # }
  end
end
