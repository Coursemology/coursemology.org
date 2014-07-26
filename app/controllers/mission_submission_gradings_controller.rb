# This controller only handles viewing and grading missions
class MissionSubmissionGradingsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_resources
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission
  before_filter :create_resources

  before_filter :load_general_course_data, only: [:new, :edit]

  # @deprecated
  def new
    @qadata = {}

    @mission.questions.each_with_index do |q,i|
      @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
    end

    @submission.answers.each do |sa|
      answer = sa.specific
      qn = sa.question
      question = qn.specific
      @qadata[qn.id.to_s + qn.class.to_s][:a] = sa

      #suggest grading for auto grading question
      if answer.class == Assessment::CodingAnswer and question.auto_graded?
        evals = sa.result_hash['eval'].select {|r| r}.length
        tests = qn.data_hash["eval"].length
        grade = (qn.max_grade * evals / tests).to_i
        ag = AnswerGrading.new
        ag.grade = grade
        @qadata[qn.id.to_s + qn.class.to_s][:g] = ag
      end
    end

    @do_grading = true

    if @submission.gradings.count > 0
      redirect_to edit_course_mission_submission_submission_grading_path(@course, @mission,@submission, @submission.gradings.first)
    end

  end

  # @deprecated
  def create
    if @submission.graded?
      flash[:error] = 'Submission has already been graded by ' + @submission.final_grading.grader.name
      redirect_to course_mission_submission_path(@course, @mission, @submission) and return
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
          break                                          O
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
    authorize! :grade, @submission
  end

  def update
    authorize! :grade, @submission

    def create_exp_transaction
      ExpTransaction.new({
                           user_course_id: @submission.std_course.id,
                           reason: "EXP for #{@submission.assessment.title}",
                           is_valid: true
                         })
    end

    # Handle single-question submissions where the grade of the entire submission equals the grade of the answer.
    gradings = []
    grading_exp_transactions_to_save = []
    exp_transaction = nil
    if @mission.single_question? then
      grading = @submission.answers.first.grading
      grading.grade = params[:grade_sum].to_i

      # Make sure we always reference a valid EXP transaction.
      exp_transaction = grading.exp_transaction || create_exp_transaction
      grading.exp_transaction = exp_transaction

      if grading.changed? then
        grading.grader = current_user
        grading.grader_course = curr_user_course
      end
      gradings <<= grading

    # Otherwise we need to assign the scores for every question.
    else
      params[:grades].each_pair do |grade_id, grade|
        grading = Assessment::Grading.find_by_id!(grade_id)
        grading.update_attributes(grade)

        # Make sure all the grades in this submission reference the same EXP transaction.
        exp_transaction ||= grading.exp_transaction || create_exp_transaction
        if grading.exp_transaction && grading.exp_transaction != exp_transaction then
          # We have a grading which used a different EXP transaction. Delete that one.
          grading.exp_transaction.is_valid = false
          grading_exp_transactions_to_save <<= grading.exp_transaction
        end
        grading.exp_transaction = exp_transaction

        if grading.changed? then
          grading.grader = current_user
          grading.grader_course = curr_user_course
        end
        gradings <<= grading
      end
    end

    exp_transaction.exp = params[:exp_sum]
    exp_transaction.giver_id = current_user.id
    exp_transaction.is_valid = true
    grading_exp_transactions_to_save <<= exp_transaction
    @submission.set_graded

    begin
      Assessment::Submission.transaction do
        grading_exp_transactions_to_save.each { |e| e.save! }
        gradings.each { |g| g.save! }
        @submission.save!
      end
    rescue ActiveRecord::RecordInvalid
      render :edit
      return
    end

    respond_to do |format|
      format.html { redirect_to course_assessment_mission_assessment_submission_assessment_gradings_path(@course, @mission, @submission),
                                notice: 'Grading has been recorded.' }
    end

    # TODO: if the transaction was rolled back:
=begin
    respond_to do |format|
      flash[:error] = "Grading appears to have failed. Did you, for example, try to give grade/exp > max? ;)"
      if edit
        format.html { redirect_to edit_course_mission_submission_submission_grading_path(@course, @mission, @submission)}
      else
        format.html { redirect_to new_course_mission_submission_submission_grading_path(@course, @mission, @submission)}
      end
    end
=end
  end

  rescue_from CanCan::AccessDenied do |exception|
    unless current_user
      redirect_to new_user_session_path
      return
    end
    if @submission.std_course == curr_user_course
      redirect_to course_mission_submission_path(@course, @mission, @submission)
    else
      flash[:error] = "You are not authorized to access the page :("
      redirect_to @course
    end
  end

private
  def load_resources
    @mission = Assessment::Mission.find_by_id!(params[:assessment_mission_id])
    @submission = Assessment::Submission.find_by_id!(params[:assessment_submission_id])
  end

  def create_resources
    # Ensure that the submission has associated gradings.
    # TODO: Implement auto grading suggestions
    @submission.answers.each do |a|
      next if a.grading

      grading = Assessment::Grading.create({
                                             answer_id: a.id,
                                             grader_id: current_user.id,
                                             grader_course_id: curr_user_course.id
                                           }, :without_protection => true)
      a.grading = grading
    end
  end
end