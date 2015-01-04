module GradingsSummaryBuilder

private

  def build_gradings_summary(with_annotations = false)
    @summary = {qn_ans: {}}

    if @grading.autograding_refresh
      @submission.eval_answer
      @grading.update_attribute :autograding_refresh, false
    end

    @assessment.questions.each_with_index do |q,i|
      @summary[:qn_ans][q.id] = { qn: q.specific, i: i + 1 }
    end

    @submission.answers.each do |sa|
      qn = sa.question
      @summary[:qn_ans][qn.id][:ans] = sa
      # @qadata[:aws][sa.id] = sa
    end

    #TODO, potential read row by row
    @grading.answer_gradings.each do |ag|
      qn = ag.answer.question
      @summary[:qn_ans][qn.id][:grade] = ag
    end

    # Include annotations in the summary
    if with_annotations
      @summary[:qn_ans].each do |qid, qn_dic|
        if qn_dic[:qn].class == Assessment::CodingQuestion
          qn_dic[:annotations] = Annotation.includes(:user_course).find_all_by_annotable_id_and_annotable_type(qn_dic[:ans].id, "Assessment::Answer")
        end
      end
    end
  end

end
