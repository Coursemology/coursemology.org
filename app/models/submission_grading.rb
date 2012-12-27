class SubmissionGrading < ActiveRecord::Base
  attr_accessible :comment, :grader_id, :publish_at, :sbm_id, :sbm_type, :total_grade

  has_many :answer_gradings
  belongs_to :grader, class_name: "User"
  belongs_to :sbm, polymorphic: true
  belongs_to :exp_transaction

  def update_exp_transaction
    puts 'update_exp'
    asm = self.sbm.get_asm
    if !self.exp_transaction
      self.exp_transaction = ExpTransaction.new
      self.exp_transaction.giver = self.grader
      self.exp_transaction.user_course =
        UserCourse.find_by_user_id_and_course_id(self.sbm.student.id, asm.course.id)
      self.exp_transaction.reason = "Exp for #{asm.get_title}"
      self.exp_transaction.is_valid = true
    end
    if asm.max_grade == 0
      self.exp_transaction.exp = 0
    else
      self.exp_transaction.exp = self.total_grade * asm.exp / asm.max_grade
    end
    self.save
    self.exp_transaction.update_user_data
  end

  def get_name
    if self.grader
      return "#{self.grader.name} (#{self.id})"
    else
      return "Auto (#{self.id})"
    end
  end
end
