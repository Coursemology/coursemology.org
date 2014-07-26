class Assessment::GradingLog < ActiveRecord::Base
  acts_as_paranoid

  belongs_to  :grader, class_name: User
  belongs_to  :grader_course, class_name: UserCourse
  belongs_to  :grading, class_name: Assessment::Grading
end