class SubmissionGradingsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission
  load_and_authorize_resource :submission_grading, through: :submission

  before_filter :load_general_course_data, only: [:new, :edit]

  # note: it only handles view & grading of missions

  def new
    @qadata = {}

    #@mission.questions.each_with_index do |q, i|
    #  @qadata[q.id] = { q: q, i: i + 1 }
    #end
    #
    #@submission.std_answers.each do |sa|
    #  @qadata[sa.question_id][:a] = sa
    #end

    @mission.get_all_questions.each_with_index do |q,i|
      @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
    end

    @submission.get_all_answers.each do |sa|
      qn = sa.qn
      @qadata[qn.id.to_s + qn.class.to_s][:a] = sa
    end

    #if @grading
    #  @grading.answer_gradings.each do |ag|
    #    qn = ag.student_answer.qn
    #    @qadata[qn.id.to_s + qn.class.to_s][:g] = ag
    #  end
    #end

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
    if @submission_grading.save
      @submission.set_graded
      @submission.final_grading = @submission_grading
      @submission_grading.update_exp_transaction
      @submission.save
      UserMailer.delay.new_grading(
          @submission.std_course.user,
          course_mission_submission_url(@course, @mission, @submission)
      )
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
    params[:ags].each do |agid, ag|
      @ag = AnswerGrading.find(agid)
      @ag.update_attributes(ag)
      @ag.grader = current_user
      @submission_grading.total_grade += ag[:grade].to_i
    end
    @submission_grading.grader = current_user
    if @submission_grading.save
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
end
