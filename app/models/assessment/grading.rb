class Assessment::Grading < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :grade, :std_course_id, :exp
  belongs_to :grader, class_name: User
  belongs_to :grader_course, class_name: UserCourse
  belongs_to :student, class_name: UserCourse, foreign_key: :std_course_id
  belongs_to :exp_transaction
  belongs_to :submission, class_name: Assessment::Submission

  has_many  :answer_gradings, class_name: Assessment::AnswerGrading
  has_many  :grading_logs, class_name: Assessment::GradingLog, dependent: :destroy

  after_save  :update_exp_transaction, if: :grade_or_exp_changed?
  after_save  :create_log, if: :grade_or_exp_changed?
  after_create  :send_notification


  def grade_or_exp_changed?
    exp_changed? or grade_changed?
  end

  def create_log
    grading_logs.create({grade: grade,
                         exp: exp,
                         grader_course_id: grader_course_id,
                         grader_id: grader_id},
                        :without_protection => true)
  end

  def update_grade
    self.grade = answer_gradings.
        joins(:answer).
        where("question_id is not null").
        group(:question_id).
        map{|x| x.grade}.sum()
  end

  def update_exp_transaction
    asm = submission.assessment

    unless self.exp_transaction
      exp_transaction = ExpTransaction.create({ giver_id: self.grader_id,
                                                    user_course_id: submission.std_course_id,
                                                    reason: "Exp for #{asm.title}",
                                                    is_valid: true,
                                                    rewardable_id: submission.id,
                                                    rewardable_type: submission.class.name },
                                                   without_protection: true)
      exp_create_or_changed = true
      update_column(:exp_transaction_id, exp_transaction.id)
    end

    self.exp_transaction.exp = exp || (grade || 0) * asm.exp / (asm.max_grade || 1)
    if submission.has_multiplier?
      self.exp_transaction.exp *= submission.multiplier
    end

    if self.submission.done?
      self.exp_transaction.exp += submission.get_bonus
    end

    # this handles the case where grade is changed, but exp is not changed.
    # we don't want to call update_exp_and_level_async twice
    exp_create_or_changed ||= self.exp_transaction.exp_changed?
    self.exp_transaction.save

    student.update_exp_and_level_async unless exp_create_or_changed
  end

  def send_notification
    course = student.course
    asm = submission.assessment
    if asm.is_mission? and asm.published? and student.is_student? and course.email_notify_enabled?(PreferableItem.new_grading)
      UserMailer.delay.new_grading(
          student,
          self)
    end
  end
end