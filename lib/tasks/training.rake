namespace :training do
  desc "Re-grade all training submissions of a specific course"
  task :re_grading_mcq, [:course_id] => :environment do |t, args|
    unless args.course_id
      puts "Please provide the course id"
      return
    end
    pref_grader = Course.find(args.course_id).mcq_auto_grader.prefer_value

    unless pref_grader == 'two-one-zero'
      return
    end

    trainings = Course.find(args.course_id).trainings

    trainings.each do |training|
      submissions = training.assessment.submissions
      submissions.each do |sub|
        correct_answers = sub.answers.where(correct:true)
        correct_answers.each do |ans|
          if ans.question.is_a?(Assessment::McqQuestion)
            grading = ans.answer_grading
            if grading
              mcq_grader(sub, ans, ans.question, pref_grader)
            end
          end
        end

        if sub.done?
          sub.update_grade
        end

      end
    end

  end

  def mcq_grader(submission, ans, mcq, pref_grader)
    grading = submission.get_final_grading
    grading.save unless grading.persisted?
    ag = grading.answer_gradings.for_question(mcq.question).first ||
        grading.answer_gradings.create({answer_id: ans.id})
    std_answers = submission.answers.where(question_id: ans.question_id)
    if pref_grader != 'two-one-zero' || (std_answers.count == 1 && std_answers.first.correct)
      ag.grade = mcq.max_grade
    else
      num_wrong_choices = mcq.options.find_all_by_correct(false).count
      uniq_wrong_attempts = std_answers.unique_attempts(false).count
      if uniq_wrong_attempts == 0
        ag.grade = mcq.max_grade
      elsif uniq_wrong_attempts >= num_wrong_choices
        ag.grade = 0
      else
        ag.grade = mcq.max_grade / 2.0
      end
    end
    ag.save
  end

end
