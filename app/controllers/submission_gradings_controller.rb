class SubmissionGradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission
  load_and_authorize_resource :submission_grading, through: :submission

  # note: it only handles view & grading of missions
  # checkout quiz_submission for quiz submission grading

  def new
    @qadata = {}

    @mission.questions.each do |q|
      @qadata[q.id] = { q: q }
    end

    @submission.std_answers.each do |sa|
      @qadata[sa.question_id][:a] = sa
    end
  end

  def create
    @submission_grading.total_grade = 0
    params[:ags].each do |ag|
      @ag = @submission_grading.answer_gradings.build(ag)
      @ag.grade = @ag.grade.to_i
      @ag.grader = current_user
      @submission_grading.total_grade += @ag.grade
    end
    @submission_grading.grader = current_user
    @submission_grading.update_exp_transaction

    if @submission_grading.save
      @submission.final_grading = @submission_grading
      @submission.save
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

    @mission.questions.each do |q|
      @qadata[q.id] = { q: q }
    end

    @submission.std_answers.each do |sa|
      @qadata[sa.question_id][:a] = sa
    end

    # student answer must be a StdAnswer
    @submission_grading.answer_gradings.each do |ag|
      @qadata[ag.student_answer.question_id][:g] = ag
    end
  end

  def update
    @submission_grading.total_grade = 0
    params[:ags].each do |agid, ag|
      @ag = AnswerGrading.find(agid)
      @ag.update_attributes(ag)
      @ag.grader = current_user
      @submission_grading.total_grade += ag[:grade].to_i
    end
    @submission_grading.grader = current_user
    @submission_grading.update_exp_transaction
    if @submission_grading.save
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
end
