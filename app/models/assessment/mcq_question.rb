class Assessment::McqQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question'
end
