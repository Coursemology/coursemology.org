class Assessment::McqQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question', class_name: 'Assessment::Question'

  def build_answer
    # Nothing to do.
  end
end
