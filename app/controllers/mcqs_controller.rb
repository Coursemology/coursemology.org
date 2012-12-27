class McqsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :training, through: :course
  load_resource :quiz, through: :course
  load_and_authorize_resource :mcq, through: [:training, :quiz]
  # may need to authorize @quiz || @training separately
  # https://github.com/ryanb/cancan/wiki/Nested-Resources
  before_filter :init_asm

  def init_asm
    @asm = @training || @quiz
  end

  def new
    @mcq.max_grade = 1
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mcq }
    end
  end

  def update_answers(mcq)
    updated = true
    params[:answers].each do |answer|
      answer['is_correct'] = answer.has_key?('is_correct')
      if answer.has_key?('id')
        ans = McqAnswer.find(answer['id'])
        ans.mcq = mcq
        # TODO: check if this answer does belong to the current question
        updated = updated && ans.update_attributes(answer)
      else
        ans = mcq.mcq_answers.build(answer)
        updated = updated && ans.save
      end
    end
    return updated
  end

  def create
    @mcq.creator = current_user
    @asm_qn = AsmQn.new
    @asm_qn.asm = @asm
    @asm_qn.qn = @mcq

    # update max grade of the asm it belongs to
    respond_to do |format|
      if @mcq.save && @asm_qn.save
        update_answers(@mcq)
        @asm.update_grade
        if @asm.is_a?(Training)
          format.html { redirect_to course_training_url(@course, @training),
                        notice: 'Question successfully added.' }
        elsif @asm.is_a?(Quiz)
          format.html { redirect_to course_quiz_url(@course, @quiz),
                        notice: 'Question successfully added.' }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def edit
  end

  def update
    updated = @mcq.update_attributes(params[:mcq])
    updated = updated && update_answers(@mcq)

    respond_to do |format|
      if updated
        @asm.update_grade
        if @asm.is_a?(Training)
          format.html { redirect_to course_training_url(@course, @training),
                        notice: 'Question successfully updated.' }
        elsif @asm.is_a?(Quiz)
          format.html { redirect_to course_quiz_url(@course, @quiz),
                        notice: 'Question successfully updated.' }
        end

      else
        format.html { render action: "edit" }
      end
    end
  end
end
