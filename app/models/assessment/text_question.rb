class Assessment::TextQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question', class_name: 'Assessment::Question'

  attr_accessible :description, :max_grade

  def build_answer
    Assessment::CodingSubmission.new({
                                       question: self
                                     }, without_protection: true)
  end
end
