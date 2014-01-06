class Assessment::McqSubmission < ActiveRecord::Base
  is_a :question_submission, as: 'as_assessment_question_submission'
end