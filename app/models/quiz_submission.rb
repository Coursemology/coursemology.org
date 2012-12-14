class QuizSubmission < ActiveRecord::Base
  attr_accessible :attempt, :open_at, :quiz_id, :student_id, :submit_at
end
