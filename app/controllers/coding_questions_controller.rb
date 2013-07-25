class CodingQuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course
  load_and_authorize_resource :coding_question, through: :training

  before_filter :init_asm

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def init_asm
    @asm = @training
  end

  def new
    @coding_question.max_grade = 1
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @coding_question }
    end
  end

  def create
    @coding_question.creator = current_user
    @coding_question.max_grade = 2
    @asm_qn = AsmQn.new
    @asm_qn.asm = @asm
    @asm_qn.qn = @coding_question
    @asm_qn.pos = @asm.asm_qns.count

    # update max grade of the asm it belongs to
    respond_to do |format|
      if @coding_question.save && @asm_qn.save
        #update_details(@coding_question)
        @asm.update_grade
        if @asm.is_a?(Training)
          format.html { redirect_to course_training_url(@course, @training),
                                    notice: 'New question added.' }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    updated = @coding_question.update_attributes(params[:coding_question])
    #updated = updated && update_answers(@mcq)

    respond_to do |format|
      if updated
        @asm.update_grade
        if @asm.is_a?(Training)
          format.html { redirect_to course_training_url(@course, @training),
                                    notice: 'Question updated.' }
        end
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @coding_question.destroy
    @asm.update_grade
    @asm.update_qns_pos
    respond_to do |format|
      format.html { redirect_to @asm.get_path }
    end
  end
end
