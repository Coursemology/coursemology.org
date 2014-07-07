class Assessment::Question < ActiveRecord::Base
  acts_as_paranoid
  acts_as_superclass as: :as_question

  default_scope { order("assessment_questions.position") }

  attr_accessible :title, :description, :max_grade

  belongs_to :creator, class_name: "User"

  #TODO, dependent: :destroy here
  has_many  :question_assessments
  #was std_answers
  has_many  :answers, class_name: Assessment::Answer, dependent: :destroy
  #These two are just for mcq question, but the foreign key is question_id
  has_many  :options, class_name: Assessment::McqOption, dependent: :destroy


  has_one :comment_topic, as: :topic

  before_update :clean_up_description, :if => :description_changed?

  #TOFIX
  def get_title
    title && !title.empty? ? title : "Question #{position}"
  end

  #clean up messed html tags
  def clean_up_description
    self.description = CoursemologyFormatter.clean_code_block(description)
  end

  def self.assessments
    Assessment.joins("LEFT JOIN  question_assessments ON question_assessments.assessment_id = assessments.id")
    .where("question_assessments.question_id IN (?)", self.all)
  end
end