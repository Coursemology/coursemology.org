class SurveyQuestion < ActiveRecord::Base
  acts_as_paranoid
  acts_as_sortable column: :pos
  default_scope { order("pos") }
  attr_accessible :type_id,:survey_id, :survey_section_id, :description, :max_response, :publish, :is_required


  belongs_to :survey
  belongs_to :survey_section
  belongs_to :type, class_name:"SurveyQuestionType"

  has_many :options, class_name:"SurveyQuestionOption", foreign_key: "question_id"
  has_many :survey_mrq_answers, foreign_key: "question_id"
  has_many :survey_essay_answers, :foreign_key => "question_id"
  has_many :files, through: :options

  amoeba do
    include_field :options
  end

  def user_answered?(user_course)
    answers = answer_for_user(user_course)
    result = answers

    if result && (not is_essay?) then
      result = answers.first
    end

    result
  end

  def answer_for_user(user_course)
    is_essay? ?
        self.survey_essay_answers.where(user_course_id: user_course).first :
        self.survey_mrq_answers.where(user_course_id: user_course)
  end

  def essay_answers(include_phantom = true)
    include_phantom ? survey_essay_answers : survey_essay_answers.includes(:user_course).where("user_courses.is_phantom = 0 and user_courses.role_id = 5")
  end

  def no_unique_voters(include_phantom = true)
    (include_phantom ? self.survey_mrq_answers : self.survey_mrq_answers.includes(:user_course).where("user_courses.is_phantom = 0 and user_courses.role_id = 5")).count(:user_course_id, distinct:true)
  end

  def is_essay?
    type == SurveyQuestionType.Essay.first
  end
end
