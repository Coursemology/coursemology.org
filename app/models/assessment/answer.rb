class Assessment::Answer < ActiveRecord::Base
  acts_as_paranoid

  scope :coding,
        -> { joins("INNER JOIN assessment_questions on assessment_answers.question_id =
            assessment_questions.id and assessment_questions.as_question_type = 'Assessment::CodingQuestion'")
        .readonly(false) }

  scope :finalised,  -> { where(finalised: true) }

  belongs_to  :question, class_name: Assessment::Question
  belongs_to  :std_course, class_name: "UserCourse"
  belongs_to  :submission, class_name: Assessment::Submission
  has_many  :annotations, as: :annotable, dependent: :destroy
  has_one   :answer_grading, class_name: Assessment::AnswerGrading, dependent: :destroy
  has_many  :answer_options, class_name: Assessment::AnswerOption
  has_many  :options, class_name: Assessment::McqOption, through: :answer_options

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

  def self.unique_attempts(correct = nil)
    options = Assessment::AnswerOption.select(:option_id).where("assessment_answer_options.answer_id IN (?)", self.all).
        joins("LEFT JOIN assessment_mcq_options ON assessment_mcq_options.id = assessment_answer_options.option_id").uniq
    if correct.nil?
      options
    else
      options.where("assessment_mcq_options.correct = ?", correct)
    end
  end

  def self.group_by_options
    self.joins("INNER JOIN (SELECT *,  GROUP_CONCAT(option_id SEPARATOR ' ') AS options FROM assessment_answer_options GROUP BY answer_id) aao ON assessment_answers.id = aao.answer_id").
        select("assessment_answers.*,  COUNT(options) AS count").
        group("aao.options").
        order("assessment_answers.created_at")
  end

  def result_hash
    self.answer ? JSON.parse(self.result) : {}
  end

  def can_run_test?(uc)
    attempt_left > 0 || uc.is_staff?
  end
end