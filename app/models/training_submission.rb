class TrainingSubmission < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers
  include Sbm

  # current_step starts from 1, not 0
  attr_accessible :current_step, :multiplier, :open_at, :std_course_id, :submit_at, :training_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :training

  has_many :std_mcq_answers, through: :sbm_answers,
           source: :answer, source_type: "StdMcqAnswer"

  has_many :std_coding_answers, through: :sbm_answers,
           :source => :answer, :source_type => "StdCodingAnswer"

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

  def update_grade
    subm_grading = self.get_final_grading
    subm_grading.update_grade
    subm_grading.update_exp_transaction
    subm_grading.save
  end

  def auto_grade(question, std_sbm_ans)
    grade = 0
    subm_grading = self.get_final_grading

    # currently, there is one answer grading for each question
    # when there are multiple answer for one question, only the one
    # that is counted is graded (and attached with the grading)
    std_ans = std_sbm_ans.answer
    if question.class == CodingQuestion
      ags = subm_grading.answer_gradings.select{ |g| g.student_answer.qn == question}
      ag = ags.first || subm_grading.answer_gradings.build
      std_answers = question.std_coding_answers.find_all_by_student_id(std_ans.student_id)
    elsif question.class == Mcq and std_ans.mcq_answer.is_correct
      ags = subm_grading.answer_gradings.select { |g| g.student_answer.qn == question }
      ag = ags.first || subm_grading.answer_gradings.build
      std_answers = self.std_mcq_answers.where(mcq_id: question.id)
    end

    # Strategy: mark again every time I receive a new answer
    # - Get all student answers for the question
    # - Get all possible answers for the question
    # - Find the first answer that is correct
    #   + First try => 2pts
    #   + If all wrong answers are ticked off => 0pt
    #   + Otherwise 1pt

    if std_answers.count == 0 || question.class == CodingQuestion
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

  def status
    if self.submission_gradings.count > 0
      "Auto graded"
    else
      "Pending"
    end
  end

  def graded?
    if self.submission_gradings.count > 0
      true
    else
      false
    end
  end
end
