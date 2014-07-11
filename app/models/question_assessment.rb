class QuestionAssessment < ActiveRecord::Base

  default_scope { order("question_assessments.position") }

  belongs_to :assessment
  #TOFIX, if we put depend: :destroy here, what will happen if question is pointed to multiple assessments
  belongs_to :question, class_name: "Assessment::Question"

  def self.reordering(new_order)
    new_order.each_with_index do |id, index|
      asm_qn = self.find_by_question_id(id.to_i)
      asm_qn.position = index
      asm_qn.save
    end
  end
end