class Assessment::McqQuestionsController < Assessment::QuestionsController
  # https://github.com/ryanb/cancan/wiki/Nested-Resources

  def update_answers(mcq)
    updated = true
    param_options = params["assessment_mcq_question"][:options]
    if param_options
      param_options.each do |i, option|
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
    # update max grade of the asm it belongs to
    saved = super
    respond_to do |format|
      if saved
        update_answers(@question)
        if @assessment.as_assessment.is_a?(Assessment::Training)
          format.html { redirect_to course_assessment_training_url(@course, @assessment.as_assessment),
                        notice: 'New question added.' }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    super
    updated = update_answers(@question) && @question.update_attributes(params["assessment_mcq_question"])
    respond_to do |format|
      if updated && @question.save
        if @assessment.as_assessment.is_a?(Assessment::Training)
          format.html { redirect_to course_assessment_training_url(@course, @assessment.as_assessment),
                                    notice: 'Question updated.' }
        end

      else
        format.html { render action: "edit" }
      end
    end
  end
end
