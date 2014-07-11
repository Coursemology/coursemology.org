class Assessment::McqsController < Assessment::QuestionsController
  # https://github.com/ryanb/cancan/wiki/Nested-Resources
  before_filter {|c| c.build_resource Assessment::McqQuestion}

  def new
    @question.max_grade = 2
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  def update_answers(mcq)
    updated = true
    if params[:options]
      params[:options].each do |i, option|
        option['correct'] = option.has_key?('correct')
        if option.has_key?('id')
          opt = Assessment::McqOption.find(option['id'])
          opt.question = mcq.question
          # TODO: check if this answer does belong to the current question
          if !option['text'] || option['text'] == ''
            opt.destroy
          else
            updated = updated && opt.update_attributes(option)
          end
        elsif option['text'] && option['text'] != ''
          opt = mcq.options.build(option)
          updated = updated && opt.save
        end
      end
    end
    updated
  end

  def create
    @question.creator = current_user
    qa = @assessment.question_assessments.new
    qa.question = @question.question
    @question.question.position = @assessment.questions.count

    # update max grade of the asm it belongs to
    respond_to do |format|
      if @question.save && qa.save
        update_answers(@question)
        @assessment.update_grade
        if @assessment.as_assessment.is_a?(Assessment::Training)
          format.html { redirect_to course_assessment_training_url(@course, @assessment.as_assessment),
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
    updated = update_answers(@question) && @question.update_attributes(params["assessment_mcq_question"])
    respond_to do |format|
      if updated && @question.save
        @assessment.update_grade
        if @assessment.as_assessment.is_a?(Assessment::Training)
          format.html { redirect_to course_assessment_training_url(@course, @assessment.as_assessment),
                                    notice: 'Question updated.' }
        end

      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @question.destroy
    @assessment.update_grade
    @assessment.update_qns_pos
    respond_to do |format|
      format.html { redirect_to @asm.get_path }
    end
  end
end
