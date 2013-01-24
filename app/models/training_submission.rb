class TrainingSubmission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  # current_step starts from 1, not 0
  attr_accessible :current_step, :open_at, :std_course_id, :submit_at, :training_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :training

  has_many :std_mcq_answers, through: :sbm_answers,
      source: :answer, source_type: "StdMcqAnswer"

  def get_asm
    return self.training
  end

  def get_path
    return course_training_training_submission_path(training.course, training, self)
  end

  def get_new_grading_path
    return '#'
  end

  def done?
    return current_step >= self.training.mcqs.count
  end

  def auto_grade(mcq, std_sbm_ans)
    grade = 0
    subm_grading = self.get_final_grading

    # currently, there is one answer grading for each question
    # when there are multiple answer for one question, only the one
    # that is counted is graded (and attached with the grading)
    std_ans = std_sbm_ans.answer
    if std_ans.mcq_answer.is_correct
      ags = subm_grading.answer_gradings.select { |g| g.student_answer.mcq == mcq }
      ag = ags.first || subm_grading.answer_gradings.build

      # Strategy: mark again every time I receive a new answer
      # - Get all student answers for the question
      # - Get all possible answers for the question
      # - Find the first answer that is correct
      #   + First try => 2pts
      #   + If all wrong answers are ticked off => 0pt
      #   + Otherwise 1pt
      std_answers = mcq.std_mcq_answers.find_all_by_student_id(std_ans.student_id)
      if std_answers.count == 0
        ag.grade = 2
        ag.student_answer = std_ans
        std_sbm_ans.is_final = true
      elsif !ag.grade  # first correct attempt
        num_wrong_choices = mcq.mcq_answers.find_all_by_is_correct(false).count
        uniq_answers = std_answers.uniq { |stda| stda.mcq_answer_id }
        uniq_wrong_attempts = uniq_answers.select { |stda| !stda.mcq_answer.is_correct }
        ag.grade = (num_wrong_choices == uniq_wrong_attempts.count) ? 0 : 1
        ag.student_answer = std_ans
        std_sbm_ans.is_final = true
      end
      grade = ag.grade
      ag.save
      std_sbm_ans.save
    end

    subm_grading.update_grade
    subm_grading.update_exp_transaction
    subm_grading.save
    return grade
  end
end
