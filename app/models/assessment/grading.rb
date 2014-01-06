class Assessment::Grading < ActiveRecord::Base
  belongs_to :question_submission
  belongs_to :grader, class_name: 'User'
  belongs_to :grader_course, class_name: 'UserCourse'
  belongs_to :exp_transaction, class_name: 'ExpTransaction'
end