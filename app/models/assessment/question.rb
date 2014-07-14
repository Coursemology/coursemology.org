class Assessment::Question < ActiveRecord::Base
  acts_as_paranoid
  acts_as_superclass as: :as_question

  attr_accessible :title, :description, :max_grade

  belongs_to :creator, class_name: "User"

  #TODO, dependent: :destroy here
  has_many  :question_assessments, dependent: :destroy
  #was std_answers
  has_many  :answers, class_name: Assessment::Answer, dependent: :destroy
  #These two are just for mcq question, but the foreign key is question_id
  has_many  :options, class_name: Assessment::McqOption, dependent: :destroy


  has_one :comment_topic, as: :topic

  before_update :clean_up_description, :if => :description_changed?
  after_update  :update_assessment_grade, if: :max_grade_changed?

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

  def update_assessment_grade
    puts "update grade", self.question_assessments.count
    self.question_assessments.each do |qa|
      qa.assessment.update_grade
    end
  end

  def specific
    as_question
  end
end