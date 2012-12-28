class QuizzesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :quiz, through: :course

  def index
  end

  def show
    @mcqs = @quiz.mcqs
  end

  def new
  end

  def create
    @quiz.pos = @course.quizzes.size - 1
    @quiz.creator = current_user
    respond_to do |format|
      if @quiz.save
        format.html { redirect_to course_quiz_url(@course, @quiz),
                      notice: 'Training was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @quiz.update_attributes(params[:quiz])
        format.html { redirect_to course_quiz_url(@course, @quiz),
                      notice: 'Training was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @quiz.destroy

    respond_to do |format|
      format.html { redirect_to course_quizs_url }
    end
  end
end
