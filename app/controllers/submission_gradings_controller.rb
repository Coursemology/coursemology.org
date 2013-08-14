class SubmissionGradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission
  load_and_authorize_resource :submission_grading, through: :submission

  before_filter :load_general_course_data, only: [:new, :edit]

  # note: it only handles view & grading of missions

  def new
    @qadata = {}

    @mission.get_all_questions.each_with_index do |q,i|
      @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
    end

    @submission.get_all_answers.each do |sa|
      qn = sa.qn
      @qadata[qn.id.to_s + qn.class.to_s][:a] = sa
    end

    @do_grading = true

    if @submission.submission_gradings.count > 0
      redirect_to edit_course_mission_submission_submission_grading_path(@course, @mission,@submission, @submission.submission_gradings.first)
    end

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

    params[:ags].each do |ag|
      @ag = @submission_grading.answer_gradings.build(ag)
      unless validate_gradings(@ag, ag)
        invalid_assign = true
        break
      end

      @ag.grader = current_user
      puts @ag.to_json
      puts @submission_grading.to_json
      @submission_grading.total_grade += @ag.grade
      @submission_grading.total_exp += @ag.exp
    end
    @submission_grading.grader = current_user
    if invalid_assign
      grade_error_response
    elsif @submission_grading.save
      @submission.set_graded
      @submission.final_grading = @submission_grading
      @submission_grading.update_exp_transaction
      @submission.save

      if @course.email_notify_enabled? PreferableItem.new_grading
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
    params[:ags].each do |agid, ag|
      @ag = AnswerGrading.find(agid)
      unless validate_gradings(@ag, ag)
        invalid_assign = true
        break
      end
      @ag.update_attributes(ag)
      @ag.grader = current_user
      @submission_grading.total_grade += ag[:grade].to_i
      @submission_grading.total_exp += ag[:exp].to_i
      @submission_grading.last_grade_updated = Time.now
    end
    @submission_grading.grader = current_user
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
end