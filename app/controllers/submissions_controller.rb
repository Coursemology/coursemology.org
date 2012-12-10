class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :submission, through: :assignment

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :assignment, only: :listall

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
    # has submission, has assignment, has student answers
    @qadata = {}

    if @assignment.auto_graded > 0
      template = "submissions/show_mcq"
      @assignment.mcqs.each do |mcq|
        @qadata[mcq.id] = { q: mcq }
      end
    else
      template = "submissions/show_question"
      @assignment.questions.each do |q|
        @qadata[q.id] = { q: q }
      end
    end

    @submission.student_answers.each do |sa|
      @qadata[sa.answerable_id][:a] = sa
    end

    puts @qadata

    respond_to do |format|
      format.html { render :template => template }
    end
  end

  def new
    @mcqs = @assignment.mcqs
    @questions = @assignment.questions
    respond_to do |format|
      format.html
    end
  end

  def create
    @submission.student_id = current_user.id
    if params[:auto_graded].to_f > 0
      params[:answers].each do |qid, ansid|
        @mcq = Mcq.find(qid)
        sa = @submission.student_answers.build({
          answer_id: ansid
        })
        sa.answerable = @mcq
      end
    else
      params[:answers].each do |qid, ans|
        @wq = Question.find(qid)
        sa = @submission.student_answers.build({
          text: ans,
        })
        sa.answerable = @wq
      end
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
