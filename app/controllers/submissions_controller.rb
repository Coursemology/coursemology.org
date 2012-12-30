class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :mission, only: :listall

  before_filter :load_sidebar_data, only: [:index, :listall, :show, :new]

  def index
  end

  def listall
    if params.has_key?(:student_id)
      @submissions = Submission.all_student(@course, current_user)
    else
      puts @course.to_json
      @submissions = Submission.all_course(@course)
    end
  end

  def show
    @qadata = {}

    if params[:grading_id]
      @grading = SubmissionGrading.find(grading_id)
    else
      @grading = @submission.final_grading
    end

    @mission.questions.each do |q|
      @qadata[q.id] = { q: q }
    end

    @submission.std_answers.each do |sa|
      @qadata[sa.question.id][:a] = sa
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        @qadata[ag.student_answer.question_id][:g] = ag
      end
    end

    puts @qadata

    respond_to do |format|
      format.html { render "submissions/show_question" }
    end
  end

  def new
    @questions = @mission.questions
    respond_to do |format|
      format.html
    end
  end

  def create
    @submission.student_id = current_user.id

    params[:answers].each do |qid, ans|
      @wq = Question.find(qid)
      sa = @submission.std_answers.build({
        text: ans,
      })
      sa.question = @wq
    end
    if @submission.save
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end
  end
end
