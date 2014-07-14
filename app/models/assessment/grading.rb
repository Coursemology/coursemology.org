class Assessment::Grading < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :grader, class_name: UserCourse, foreign_key: :grader_course_id
  belongs_to :exp_transaction
  belongs_to :submission, class_name: Assessment::Submission

  has_many  :answer_gradings, class_name: Assessment::AnswerGrading
  has_many  :grading_logs, class_name: Assessment::GradingLog, dependent: :destroy

  after_save :update_exp_transaction, if: :exp_changed?

  def update_exp_transaction
    sbm = self.submission
    asm = sbm.assessment

    unless self.exp_transaction
      self.exp_transaction = ExpTransaction.new
      self.exp_transaction.giver = self.grader.user
      self.exp_transaction.user_course = self.submission.std_course
      self.exp_transaction.reason = "Exp for #{asm.title}"
      self.exp_transaction.is_valid = true
      self.exp_transaction.rewardable = sbm
      self.save
    end

    self.exp_transaction.exp = self.exp || self.grde * asm.exp / asm.max_grade
    if sbm.has_multiplier?
      self.exp_transaction.exp *= sbm.multiplier
    else
      self.exp_transaction.exp += sbm.get_bonus
    end

    self.exp_transaction.save
    # sbm.tags.each { |tag| tag.update_exp_for_std(sbm.std_course_id) }
    self.exp_transaction.update_user_data
  end
end