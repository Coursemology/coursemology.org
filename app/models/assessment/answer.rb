class Assessment::Answer < ActiveRecord::Base
  acts_as_paranoid
  acts_as_superclass as: :as_answer

  scope :coding,
        -> { joins("INNER JOIN assessment_questions on assessment_answers.question_id =
            assessment_questions.id and assessment_questions.as_question_type = 'Assessment::CodingQuestion'")
        .readonly(false) }

  scope :finalised,  -> { where(finalised: true) }

  attr_accessible :std_course_id, :question_id, :content, :submission_id, :attempt_left

  belongs_to  :question, class_name: Assessment::Question
  belongs_to  :std_course, class_name: "UserCourse"
  belongs_to  :submission, class_name: Assessment::Submission
  has_many  :annotations, as: :annotable, dependent: :destroy
  has_one   :answer_grading, class_name: Assessment::AnswerGrading, dependent: :destroy

  has_one :comment_topic, as: :topic

  #TODO
  # def get_url
  #   sbm_answers.first.sbm.get_url
  # end
  #
  # def qn_id
  #   self.question_id
  # end

  def self.unique_attempts(correct = nil)
    options = Assessment::AnswerOption.select(:option_id).where(answer_id: self.pluck(:as_answer_id)).
        joins("LEFT JOIN assessment_mcq_options ON assessment_mcq_options.id = assessment_answer_options.option_id").uniq
    if correct.nil?
      options
    else
      options.where("assessment_mcq_options.correct = ?", correct)
    end
  end

  def can_run_test?(uc)
    attempt_left > 0 || uc.is_staff?
  end
end