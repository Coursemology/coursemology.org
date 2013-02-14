class McqsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :training, through: :course
  load_resource :quiz, through: :course
  load_and_authorize_resource :mcq, through: [:training, :quiz]
  # may need to authorize @quiz || @training separately
  # https://github.com/ryanb/cancan/wiki/Nested-Resources
  before_filter :init_asm

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

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
    if params[:answers]
      updated = true
      params[:answers].each do |i, answer|
        puts answer
        answer['is_correct'] = answer.has_key?('is_correct')
        if answer.has_key?('id')
          ans = McqAnswer.find(answer['id'])
          ans.mcq = mcq
          # TODO: check if this answer does belong to the current question
          if !answer['text'] || answer['text'] == ''
            ans.destroy
          else
            updated = updated && ans.update_attributes(answer)
          end
        elsif answer['text'] && answer['text'] != ''
          ans = mcq.mcq_answers.build(answer)
          updated = updated && ans.save
        end
      end
    end
    return updated
  end

  def create
    @mcq.creator = current_user
    @mcq.max_grade = 2
    @asm_qn = AsmQn.new
    @asm_qn.asm = @asm
    @asm_qn.qn = @mcq
    @asm_qn.pos = @asm.asm_qns.count

    # update max grade of the asm it belongs to
    respond_to do |format|
      if @mcq.save && @asm_qn.save
        update_answers(@mcq)
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
    updated = @mcq.update_attributes(params[:mcq])
    updated = updated && update_answers(@mcq)

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

  def destroy
    @mcq.destroy
    respond_to do |format|
      format.html { redirect_to @asm.get_path }
    end
  end
end
