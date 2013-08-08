module AutoGrader

  def AutoGrader.mcq_select_all_grader(training_submission, question, std_sbm_ans)
    grade = 0
    subm_grading = training_submission.get_final_grading
    std_ans = std_sbm_ans.answer

    if std_ans.selected_choices != question.correct_answers
      return false, grade
    end

    # correct answer
    ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question }
    # keep only 1 answer grading per question
    ag = ags.first || subm_grading.answer_gradings.build
    ag.grade = 2
    ag.student_answer = std_ans
    ag.save

    std_sbm_ans.is_final = true
    std_sbm_ans.save

    grade = ag.grade

    return true, grade
  end

  def AutoGrader.mcq_grader(training_submission, question, std_sbm_ans)
    # normal grading scheme where for each question:
    # - students can try as many times as they want
    # - they will get 2 points whenever they get the answer correctly
    grade = 0
    subm_grading = training_submission.get_final_grading
    std_ans = std_sbm_ans.answer

    is_correct = std_ans.mcq_answer.is_correct

    if is_correct
      ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question }
      # keep only 1 answer grading per question
      ag = ags.first || subm_grading.answer_gradings.build
      ag.grade = 2
      ag.student_answer = std_ans
      std_sbm_ans.is_final = true
      ag.save
      grade = ag.grade
      std_sbm_ans.save
    end

    return is_correct, grade
  end

  def AutoGrader.toz_mcq_grader(training_submission, question, std_sbm_ans)
    # grading answer in training by score 2-1-0
    # 2 for answer correctly the first time
    # 1 for answer correctly in subsequence attempts
    # 0 for only answering correctly in the last choice
    grade = 0
    subm_grading = training_submission.get_final_grading
    std_ans = std_sbm_ans.answer
    is_correct = std_ans.mcq_answer.is_correct

    if !is_correct
      return is_correct, grade
    end

    # currently, there is one answer grading for each question
    # when there are multiple answer for one question, only the one
    # that is counted is graded (and attached with the grading)
    if std_ans.mcq_answer.is_correct
      ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question }
      ag = ags.first || subm_grading.answer_gradings.build
    end

    # Strategy: mark again every time I receive a new answer
    # - Get all student answers for the question
    # - Get all possible answers for the question
    # - Find the first answer that is correct
    #   + First try => 2pts
    #   + If all wrong answers are ticked off => 0pt
    #   + Otherwise 1pt

    std_answers = training_submission.std_mcq_answers.where(mcq_id: question.id)
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
    return is_correct, grade
  end

  def AutoGrader.coding_question_grader(training_submission, question, std_sbm_ans)
    # note: this grader doesn't update the EXP of the student
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

    return grade
  end
end
