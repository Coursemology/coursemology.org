class Assessment::AnswerGrading < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :answer_id, :grade

  belongs_to :grader, class_name: UserCourse, foreign_key: :grader_course_id
  belongs_to :answer, class_name: Assessment::Answer, foreign_key: :answer_id
  belongs_to :grading, class_name: Assessment::Grading, foreign_key: :grading_id

  has_many  :logs, class_name: Assessment::AnswerGradingLog, foreign_key: :answer_grading_id

  after_save :create_log, if: :grade_changed?

  def self.for_question(qn)
    self.joins(:answer).where("assessment_answers.question_id = ?", qn).readonly(false)
  end

  def create_log
    logs.create({grade: grade, grader_course_id: grader_course_id})
  end
end