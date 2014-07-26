class Assessment::Grading < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :grader, class_name: User
  belongs_to :grader_course, class_name: UserCourse
  belongs_to :student, class_name: UserCourse, foreign_key: :std_course_id
  belongs_to :exp_transaction
  belongs_to :submission, class_name: Assessment::Submission

  has_many  :answer_gradings, class_name: Assessment::AnswerGrading
  has_many  :grading_logs, class_name: Assessment::GradingLog, dependent: :destroy

  after_save :update_exp_transaction, if: :grade_or_exp_changed?
  after_save :create_log, if: :grade_or_exp_changed?


  def grade_or_exp_changed?
    exp_changed? or grade_changed?
  end

  def create_log
    grading_logs.create({grade: grade, exp: exp, grader_course_id: grader_course_id, grader_id: grader_id}, :without_protection => true)
  end

  def update_grade
    self.grade = answer_gradings.sum(&:grade)
  end

  def update_exp_transaction
    asm = submission.assessment

    unless self.exp_transaction
      self.exp_transaction = ExpTransaction.new
      self.exp_transaction.giver = self.grader
      self.exp_transaction.user_course = submission.std_course
      self.exp_transaction.reason = "Exp for #{asm.title}"
      self.exp_transaction.is_valid = true
      self.exp_transaction.rewardable = submission
      self.save
    end

    self.exp_transaction.exp = self.exp || (self.grade || 0) * asm.exp / asm.max_grade
    if submission.has_multiplier?
      self.exp_transaction.exp *= submission.multiplier
    else
      self.exp_transaction.exp += submission.get_bonus
    end

    self.exp_transaction.save
    # sbm.tags.each { |tag| tag.update_exp_for_std(sbm.std_course_id) }
    self.exp_transaction.update_user_data
  end
end