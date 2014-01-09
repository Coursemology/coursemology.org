class Assessment::Grading < ActiveRecord::Base
  belongs_to :answer
  belongs_to :grader, class_name: 'User'
  belongs_to :grader_course, class_name: 'UserCourse'
  belongs_to :exp_transaction, class_name: 'ExpTransaction'

  attr_accessible :grade

  validate :grade_less_than_question_maximum
  validate :exp_less_than_assignment_maximum

private
  def grade_less_than_question_maximum
    if grade && answer.question && answer.question.max_grade < grade then
      errors.add(:grade, 'cannot be greater than question maximum')
    end
  end

  def exp_less_than_assignment_maximum
    if exp_transaction && answer.question && answer.question.assessment.exp < exp_transaction.exp then
      errors.add(:exp, 'cannot be greater than assignment maximum')
    end
  end
end