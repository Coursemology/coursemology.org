class Assessment::Answer < ActiveRecord::Base
  acts_as_paranoid

  scope :coding,
        joins("INNER JOIN assessment_questions on assessment_answers.question_id =
            assessment_questions.id and assessment_questions.as_question_type = 'Assessment::CodingQuestion'")
        .readonly(false)

  belongs_to  :question, class_name: Assessment::Question
  belongs_to  :std_course, class_name: "UserCourse"
  belongs_to  :submission, class_name: Assessment::Submission
  has_many  :annotations, as: :annotable, dependent: :destroy
  has_one   :answer_grading, class_name: Assessment::AnswerGrading

  has_one :comment_topic, as: :topic


  alias_method :qn, :question

  #TODO
  # def get_url
  #   sbm_answers.first.sbm.get_url
  # end
  #
  # def qn_id
  #   self.question_id
  # end

  def result_hash
    self.answer ? JSON.parse(self.result) : {}
  end

  def can_run_test?(uc)
    attempt_left > 0 || uc.is_staff?
  end
end