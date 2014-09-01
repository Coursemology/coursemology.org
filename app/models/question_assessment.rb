class QuestionAssessment < ActiveRecord::Base
  acts_as_sortable

  default_scope { order("question_assessments.position") }

  belongs_to :assessment
  #TOFIX, if we put depend: :destroy here, what will happen if question is pointed to multiple assessments
  belongs_to :question, class_name: "Assessment::Question"

  after_create  :update_assessment_grade
  after_destroy :update_assessment_grade, :update_question_pos

  def update_assessment_grade
      assessment.update_grade
  end

  def update_question_pos
    assessment.update_qns_pos
  end
end