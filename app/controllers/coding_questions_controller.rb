class CodingQuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :training, through: :course
  # load_resource :quiz, through: :course
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

  #def update_details(coding_question)
  #  if params[:answers]
  #    updated = true
  #    params[:answers].each do |i, answer|
  #      puts answer
  #      answer['is_correct'] = answer.has_key?('is_correct')
  #      if answer.has_key?('id')
  #        ans = McqAnswer.find(answer['id'])
  #        ans.mcq = mcq
  #        # TODO: check if this answer does belong to the current question
  #        if !answer['text'] || answer['text'] == ''
  #          ans.destroy
  #        else
  #          updated = updated && ans.update_attributes(answer)
  #        end
  #      elsif answer['text'] && answer['text'] != ''
  #        ans = mcq.mcq_answers.build(answer)
  #        updated = updated && ans.save
  #      end
  #    end
  #  end
  #  return updated
  #end

  def create
    @coding_question.creator = current_user
    @coding_question.max_grade = 2
    @asm_qn = AsmQn.new
    @asm_qn.asm = @asm
    @asm_qn.qn = @coding_question
    @asm_qn.pos = @asm.asm_qns.count
    logger.info "Logging"
    logger.info @coding_question.description
    logger.info @coding_question.comments
    logger.info @coding_question.step_name
    logger.info @coding_question.data



    # update max grade of the asm it belongs to
    respond_to do |format|
      if @coding_question.save && @asm_qn.save
        #update_details(@coding_question)
        @asm.update_grade
        if @asm.is_a?(Training)
          format.html { redirect_to course_training_url(@course, @training),
                                    notice: 'New question added.' }
        elsif @asm.is_a?(Quiz)
          format.html { redirect_to course_quiz_url(@course, @quiz),
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
        elsif @asm.is_a?(Quiz)
          format.html { redirect_to course_quiz_url(@course, @quiz),
                                    notice: 'Question updated.' }
        end

      else
        format.html { render action: "edit" }
      end
    end
  end
end
