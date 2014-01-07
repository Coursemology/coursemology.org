class Assessment::TextQuestion < ActiveRecord::Base
  is_a :question, as: 'as_assessment_question', class_name: 'Assessment::Question'
end
