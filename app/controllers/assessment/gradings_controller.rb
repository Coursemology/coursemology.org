class Assessment::GradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, through: :course
  load_and_authorize_resource :submission, class: "Assessment::Submission", through: :assessment
  load_and_authorize_resource :grading, through: :submission, class: "Assessment::Grading"

  before_filter :load_general_course_data, only: [:new, :edit, :show]
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

    @submission.eval_answer

    @submission.answers.each do |ans|
      qn = ans.question
      @summary[:qn_ans][qn.id][:ans] = ans

      #suggest grading for auto grading question
      if qn.is_a?(Assessment::CodingQuestion) && qn.auto_graded?
        results = ans.result_hash["eval"]
        evals = results ? results.select {|r| r}.length : 0
        tests = qn.data_hash["eval"].length
        tests = tests == 0 ? 1 : tests
        grade = (qn.max_grade * evals / tests).to_i
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
    build_summary
  end

  def show
    if curr_user_course.is_staff?
      redirect_to edit_course_assessment_submission_grading_path(@course, @assessment, @submission, @grading)
      return
    end
    build_summary
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

  def build_summary
    @summary = {qn_ans: {}}

    if @grading.autograding_refresh
      @submission.eval_answer
      @grading.update_attribute :autograding_refresh, false
    end

    @assessment.questions.each_with_index do |q,i|
      @summary[:qn_ans][q.id] = { qn: q.specific, i: i + 1 }
    end

    @submission.answers.each do |sa|
      qn = sa.question
      @summary[:qn_ans][qn.id][:ans] = sa
      # @qadata[:aws][sa.id] = sa
    end

    #TODO, potential read row by row
    @grading.answer_gradings.each do |ag|
      qn = ag.answer.question
      @summary[:qn_ans][qn.id][:grade] = ag
    end
  end
end
