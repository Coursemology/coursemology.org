module Sbm
  def get_asm
    raise NotImplementedError
  end

  def get_final_grading
    if self.submission_gradings
      self.submission_gradings.order("created_at").last
    else
      return nil
    end
  end

  def clear_final_answer(qn)
    self.sbm_answers.final.each do |sbm_ans|
      if sbm_ans.answer.qn == qn
        sbm_ans.final = false
        sbm_ans.save
        break
      end
    end
  end
end
