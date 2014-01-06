class SurveyQuestion < ActiveRecord::Base
  acts_as_paranoid
  default_scope { order("pos") }
  attr_accessible :type_id,:survey_id, :survey_section_id, :description, :max_response, :publish


  belongs_to :survey
  belongs_to :survey_section
  belongs_to :type, class_name:"SurveyQuestionType"

  has_many :options, class_name:"SurveyQuestionOption", foreign_key: "question_id"
  has_many :survey_mrq_answers, foreign_key: "question_id"
  has_many :survey_essay_answers, :foreign_key => "question_id"
  has_many :files, through: :options

  def answer_for_user(user_course)
    type == SurveyQuestionType.Essay.first ?
        self.survey_essay_answers.where(user_course_id: user_course).first :
        self.survey_mrq_answers.where(user_course_id: user_course)
  end

  def no_unique_voters
    self.survey_mrq_answers.count(:user_course_id, distinct:true)
  end
end
