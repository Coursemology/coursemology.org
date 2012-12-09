class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :submission, through: :assignment

  def index

  end

  def show

  end

  def new
    @mcqs = @assignment.mcqs
    @written_questions = @assignment.written_questions
    respond_to do |format|
      format.html
    end
  end

  def create
    @submission.student_id = current_user.id
    params[:answers].each do |qid, ans|
      @wq = WrittenQuestion.find(qid)
      sa = @submission.student_answers.build({
        text: ans,
      })
      sa.answerable = @wq
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
