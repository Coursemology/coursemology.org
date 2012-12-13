class McqsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :assignment, through: :course
  load_resource :training, through: :course
  load_and_authorize_resource :mcq, through: [:assignment, :training]
  # may need to authorize @assignment || @training separately
  # https://github.com/ryanb/cancan/wiki/Nested-Resources
  before_filter :init_asm

  def init_asm
    @asm = @assignment || @training
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
        ans = Answer.find(answer['id'])
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

    # update max grade of the assignment it belongs to
    respond_to do |format|
      if @mcq.save && @asm_qn.save
        update_answers(@mcq)
        @asm.update_grade
        if @assignment
          format.html { redirect_to course_assignment_url(@course, @assignment),
                        notice: 'Question successfully added.' }
        else
          format.html { redirect_to course_training_url(@course, @training),
                        notice: 'Question successfully added.' }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    updated = @mcq.update_attributes(params[:mcq])
    updated = updated && update_answers(@mcq)

    respond_to do |format|
      if updated
        @asm.update_grade
        if @assignment
          format.html { redirect_to course_assignment_url(@course, @assignment),
                        notice: 'Question successfully added.' }
        else
          format.html { redirect_to course_training_url(@course, @training),
                        notice: 'Question successfully added.' }
        end
      else
        format.html { render action: "edit" }
      end
    end
  end
end
