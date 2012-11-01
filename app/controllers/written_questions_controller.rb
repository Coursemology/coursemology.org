class WrittenQuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :written_question, through: :assignment

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @written_question }
    end
  end

  def create
    @written_question.creator = current_user
    respond_to do |format|
      if @written_question.save
        format.html { redirect_to course_assignment_written_question_url(@course, @assignment, @written_question),
                      notice: 'Assignment was successfully created.' }
        format.json { render json: @written_question, status: :created, location: @written_question }
      else
        format.html { render action: "new" }
        format.json { render json: @written_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @written_question.update_attributes(params[:written_question])
        format.html { redirect_to course_assignment_written_question_url(@course, @assignment, @written_question),
                      notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @written_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

end
