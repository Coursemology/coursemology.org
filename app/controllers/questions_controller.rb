class QuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :question, through: :assignment

  def new
    @question.max_grade = 10
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  def create
    @question.creator = current_user
    @asm_qn = AsmQn.new
    @asm_qn.asm = @assignment
    @asm_qn.qn = @question

    respond_to do |format|
      if @question.save && @asm_qn.save
        @assignment.update_grade
        format.html { redirect_to course_assignment_url(@course, @assignment),
                      notice: 'Question successfully added.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "new" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @question.update_attributes(params[:question])
        @assignment.update_grade
        format.html { redirect_to course_assignment_question_url(@course, @assignment, @question),
                      notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end
end
