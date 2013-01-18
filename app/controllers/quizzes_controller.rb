class QuizzesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :quiz, through: :course
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def index
  end

  def show
    @mcqs = @quiz.mcqs
  end

  def new
  end

  def create
    @quiz.pos = @course.quizzes.count - 1
    @quiz.creator = current_user
    respond_to do |format|
      if @quiz.save
        format.html { redirect_to course_quiz_url(@course, @quiz),
                      notice: "The quiz #{@quiz.title} has been created." }
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
                      notice: "The quiz #{@quiz.title} has been created." }
      else
        format.html { render action: "edit" }
      end
    end

  end

  def destroy
    @quiz.destroy

    respond_to do |format|
      format.html { redirect_to course_quizs_url,
                    notice: "The quiz #{@quiz.title} has been removed." }
    end
  end
end
