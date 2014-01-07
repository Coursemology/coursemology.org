class Assessment::TextSubmission < ActiveRecord::Base
  is_a :question_submission, as: 'as_assessment_question_submission', class_name: 'Assessment::QuestionSubmission'
end