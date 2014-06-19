class SubmissionGrading < ActiveRecord::Base
  attr_accessible :comment, :grader_id, :publish_at, :sbm_id, :sbm_type, :total_grade,
                  :total_exp, :grader_course_id, :autograding_refresh

  has_many :answer_gradings, dependent: :destroy

  belongs_to :grader, class_name: "User"
  belongs_to :sbm, polymorphic: true
  belongs_to :exp_transaction

  default_scope { order("created_at") }
  default_scope includes(:grader)
  def update_grade
    self.total_grade = answer_gradings.sum(&:grade)
  end

  def update_exp_transaction
    asm = self.sbm.get_asm

    unless self.exp_transaction
      self.exp_transaction = ExpTransaction.new
      self.exp_transaction.giver = self.grader
      self.exp_transaction.user_course = self.sbm.std_course
      self.exp_transaction.reason = "Exp for #{asm.get_title}"
      self.exp_transaction.is_valid = true
      self.exp_transaction.rewardable = asm
      self.save
    end
    if asm.max_grade == 0
      self.exp_transaction.exp = 0
    else
      self.exp_transaction.exp = self.total_exp || self.total_grade * asm.exp / asm.max_grade
      if sbm.has_multiplier?
        self.exp_transaction.exp *= sbm.multiplier
      else
        self.exp_transaction.exp += sbm.get_bonus
      end
    end
    self.exp_transaction.save
    asm.tags.each { |tag| tag.update_exp_for_std(sbm.std_course_id) }
    self.exp_transaction.update_user_data
    self.exp_transaction.exp
  end

  def get_name
    if self.grader
      "#{self.grader.name} (#{self.id})"
    else
      "Auto (#{self.id})"
    end
  end
end
