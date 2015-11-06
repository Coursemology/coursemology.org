class Assessment::Question < ActiveRecord::Base
  acts_as_paranoid
  acts_as_duplicable
  acts_as_superclass as: :as_question
  acts_as_taggable

  attr_accessible :creator_id, :dependent_id
  attr_accessible :title, :description, :max_grade, :attempt_limit, :staff_comments
  attr_accessible :auto_graded

  belongs_to  :creator, class_name: "User"
  belongs_to  :dependent_on, class_name: "Assessment::Question", foreign_key: "dependent_id"

  #TODO, dependent: :destroy here
  has_many  :question_assessments, dependent: :destroy
  has_many  :answers, class_name: Assessment::Answer, dependent: :destroy
  has_many  :answer_gradings, class_name: Assessment::AnswerGrading, through: :answers
  has_one   :comment_topic, as: :topic

  before_update :clean_up_description, :if => :description_changed?
  after_update  :update_assessment_grade, if: :max_grade_changed?
  after_update  :update_attempt_limit, if: :attempt_limit_changed?

  #TOFIX
  def get_title
    title && !title.empty? ? title : "Question #{question_assessments.first.position + 1}"
  end

  def answers_of_students(students)
    answers.where(std_course_id: students)
  end

  def wrong_answers_of_students(students)
    answers_of_students(students).where(correct: false)
  end

  #callback methods

  def clean_up_description
    self.description = CoursemologyFormatter.clean_code_block(description)
  end

  def update_assessment_grade
    puts "update grade", self.question_assessments.count
    self.question_assessments.each do |qa|
      qa.assessment.update_grade
    end
  end

  def update_attempt_limit
    old_tl = changed_attributes[:attempt_limit] || 0
    diff = attempt_limit - old_tl
    if diff != 0
      Thread.start {
        answers.each do |sa|
          sa.attempt_left = [0, sa.attempt_left + diff].max
          sa.save
        end
      }
    end
  end

  #proxy methods
  def self.assessments
    Assessment.joins("LEFT JOIN  question_assessments ON question_assessments.assessment_id = assessments.id")
    .where("question_assessments.question_id IN (?)", self.all).uniq
  end

  #TODO: i hope mysql is smart enough to optimize this
  def self.finalised(sbm)
    grouped_answers = "SELECT *, MIN(created_at)
                      FROM assessment_answers
                      WHERE assessment_answers.finalised = 1 and assessment_answers.submission_id = #{sbm.id}
                      GROUP BY  assessment_answers.question_id"
    self.joins("INNER JOIN (#{grouped_answers}) uaaq ON assessment_questions.id = uaaq.question_id")
  end

  #overrides
  def dup
    s = self.specific
    d = s.amoeba_dup
    qn = super
    d.question = qn
    qn.as_question = d
    qn
  end
end
