module AutoGrader
  def AutoGrader.toz_mcq_grader(training_submission, question, std_sbm_ans)
    # grading answer in training by score 2-1-0
    # 2 for answer correctly the first time
    # 1 for answer correctly in subsequence attempts
    # 0 for only answering correctly in the last choice
    grade = 0
    subm_grading = training_submission.get_final_grading

    # currently, there is one answer grading for each question
    # when there are multiple answer for one question, only the one
    # that is counted is graded (and attached with the grading)
    std_ans = std_sbm_ans.answer
    if std_ans.mcq_answer.is_correct
      ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question }
      ag = ags.first || subm_grading.answer_gradings.build
      std_answers = training_submission.std_mcq_answers.where(mcq_id: question.id)
    end

    # Strategy: mark again every time I receive a new answer
    # - Get all student answers for the question
    # - Get all possible answers for the question
    # - Find the first answer that is correct
    #   + First try => 2pts
    #   + If all wrong answers are ticked off => 0pt
    #   + Otherwise 1pt

    if std_answers.count == 0
      ag.grade = 2
      ag.student_answer = std_ans
      std_sbm_ans.is_final = true
    elsif !ag.grade  # first correct attempt
      num_wrong_choices = question.mcq_answers.find_all_by_is_correct(false).count
      uniq_answers = std_answers.uniq { |stda| stda.mcq_answer_id }
      uniq_wrong_attempts = uniq_answers.select { |stda| !stda.mcq_answer.is_correct }
      ag.grade = (num_wrong_choices == uniq_wrong_attempts.count) ? 0 : 1
      ag.student_answer = std_ans
      std_sbm_ans.is_final = true
    end
    grade = ag.grade
    ag.save
    std_sbm_ans.save

    subm_grading.update_grade
    subm_grading.update_exp_transaction
    subm_grading.save
    return grade
  end

  def AutoGrader.coding_question_grader(training_submission, question, std_sbm_ans)
    grade = 0
    subm_grading = training_submission.get_final_grading

    std_ans = std_sbm_ans.answer
    ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question}
    ag = ags.first || subm_grading.answer_gradings.build

    ag.grade = 2
    ag.student_answer = std_ans
    std_sbm_ans.is_final = true

    grade = ag.grade
    ag.save
    std_sbm_ans.save

    subm_grading.update_grade
    subm_grading.update_exp_transaction
    subm_grading.save
    return grade
  end
end
