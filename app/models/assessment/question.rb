class Assessment::Question < ActiveRecord::Base
  acts_as_paranoid
  acts_as_superclass as: :as_question

  attr_accessible :title, :description, :max_grade, :creator_id

  belongs_to :creator, class_name: "User"

  #TODO, dependent: :destroy here
  has_many  :question_assessments, dependent: :destroy
  #was std_answers
  has_many  :answers, class_name: Assessment::Answer, dependent: :destroy
  #These two are just for mcq question, but the foreign key is question_id
  has_many  :options, class_name: Assessment::McqOption, dependent: :destroy
  has_many  :answer_gradings, class_name: Assessment::AnswerGrading, through: :answers


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

  #TODO: i hope mysql is smart enough to optimize this
  def self.finalised(sbm)
    grouped_answers = "SELECT *, MIN(created_at)
                      FROM assessment_answers
                      WHERE assessment_answers.finalised = 1 and assessment_answers.submission_id = #{sbm.id}
                      GROUP BY  assessment_answers.question_id"
    self.joins("INNER JOIN (#{grouped_answers}) uaaq ON assessment_questions.id = uaaq.question_id")
  end

  def update_assessment_grade
    puts "update grade", self.question_assessments.count
    self.question_assessments.each do |qa|
      qa.assessment.update_grade
    end
  end
end